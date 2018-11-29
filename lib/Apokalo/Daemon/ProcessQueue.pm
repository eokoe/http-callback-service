package Apokalo::Daemon::ProcessQueue;
use Moo;
use utf8;
use Apokalo::SchemaConnected;
use Apokalo::Logger;
use DateTime;
use Apokalo::API::Object::HTTPRequest;
use UUID::Tiny qw/is_uuid_string/;
use HTTP::Async;
use HTTP::Request;
use Apokalo::TrapSignals;
use List::MoreUtils qw/first_index/;
use JSON;
use Encode qw(encode);
use JSON::MaybeXS qw( decode_json );

has 'schema' => ( is => 'rw', lazy => 1, builder => \&GET_SCHEMA );
has 'logger' => ( is => 'rw', lazy => 1, builder => \&get_logger );

has '_http_request_rs' => (
    is      => 'rw',
    builder => sub {
        shift->schema->resultset('HttpRequest');
    }
);
has '_http_request_status_rs' => (
    is      => 'rw',
    builder => sub {
        shift->schema->resultset('HttpRequestStatus');
    }
);
has '_http_response_rs' => (
    is      => 'rw',
    builder => sub {
        shift->schema->resultset('HttpResponse');
    }
);
use Time::HiRes qw(time);

my $http_ids = {};
has 'ahttp' => ( is => 'rw', lazy => 1, builder => '_build_http' );

sub _build_http {
    HTTP::Async->new( timeout => 60, max_request_time => 120, slots => 1000 );
}

sub pending_jobs {
    my ( $self, %opts ) = @_;

    my @rows = $self->_http_request_rs->search(
        {
            '-or' => [
                { 'http_request_status.done' => undef },
                {
                    'http_request_status.done' => 0,

                    -and => [
                        \' wait_until + ( retry_exp_base ^ LEAST(http_request_status.try_num, 10) * (retry_each * coalesce(http_request_status.try_num, 0))) <= now()'
                    ],

                }
            ],
            wait_until  => { '<=' => \'now()' },
            retry_until => { '>=' => \'now()' },
            (
                exists $opts{id_not_in}
                  && ref $opts{id_not_in} eq 'ARRAY' ? ( '-not' => { 'me.id' => { 'in' => $opts{id_not_in} } } ) : ()
              )

        },
        {
            rows => $opts{rows} ? $opts{rows} : 1000,
            join => 'http_request_status',
            'columns' => [
                {
                    ( map { $_ => $_ } qw/body  headers id method retry_exp_base url / ),
                    ( map { $_ => \"EXTRACT(EPOCH FROM $_)::int" } qw/retry_each retry_until wait_until created_at/ ),
                    try_num => \
                      'CASE WHEN (http_request_status.try_num IS NULL) THEN  0 ELSE http_request_status.try_num END',
                }
            ],
            result_class => 'DBIx::Class::ResultClass::HashRefInflator'
        }
    )->all;
    return @rows;
}

sub run_once {
    my ( $self, %opts ) = @_;

    my ($pending) = $self->pending_jobs( rows => 1 );
    return -2 unless $pending;

    my $async = $self->ahttp;

    $self->_prepare_request($pending);

    if ( $async->not_empty ) {
        if ( my ( $response, $iid ) = $async->wait_for_next_response(30) ) {

            # deal with $response
            $self->_set_request_status( res => $response, ref => delete $http_ids->{$iid} );
            return 1;
        }
        else {
            return -1;
        }
    }

    return -2;
}

sub listen_queue {
    my ($self) = @_;

    my $async      = $self->ahttp;
    my $logger     = $self->logger;
    my $loop_times = 0;

    # poll db each 50 ms
    my $sleep = $ENV{HTTP_CB_MIN_POLL_INTERVAL} || 0.05;

    # default to 5 seconds
    my $loops_before_rework = ( $ENV{HTTP_CB_REWORK_INTERVAL} || 5 );

    $loops_before_rework = 1    if $loops_before_rework < 1;
    $sleep               = 0.01 if $sleep < 0.01;

    $loops_before_rework = $loops_before_rework / $sleep;

    my $dbh = $self->schema->storage->dbh;

    $logger->info("LISTEN newhttp");
    $dbh->do("LISTEN newhttp");
    eval {
        while (1) {

            if ( $async->empty ) {
                ON_TERM_EXIT;
                EXIT_IF_ASKED;
            }

            ON_TERM_WAIT;
            while ( my $notify = $dbh->pg_notifies ) {
                $loop_times = 0;
            }

            if ( $loop_times == 0 ) {
                my @pendings = $self->pending_jobs( id_not_in => [ map { $http_ids->{$_}{id} } keys %{$http_ids} ] );

                $self->_prepare_request($_) for @pendings;
            }

            if ( $async->not_empty ) {

                while ( my ( $response, $iid ) = $async->next_response ) {

                    my $ref = delete $http_ids->{$iid};
                    $self->logger->debug( join ' ', 'finished', $ref->{id}, 'with code', $response->code );

                    # deal with $response
                    $self->_set_request_status( res => $response, ref => $ref );

                }
            }
            else {
                ON_TERM_EXIT;
                EXIT_IF_ASKED;
            }

            select undef, undef, undef, $sleep;
            $loop_times = 0 if ++$loop_times == 500;
        }
    };

    $logger->logconfess("Fatal error: $@") if $@;
}

sub _prepare_request {
    my ( $self, $row ) = @_;
    my @headers = $row->{headers} ? ( map { split /:\s+/, $_, 2 } split /\n/, $row->{headers} ) : ();
    my $async  = $self->ahttp;
    my $logger = $self->logger;

    my $has_next_req = grep { $_ eq 'next_req' } @headers;

    my $next_req;
    if ( $has_next_req ) {

        my $next_req_index = first_index { $_ eq 'next_req' } @headers;
        $next_req = $headers[ $next_req_index + 1 ];

        eval { $next_req = decode_json($next_req) };
        $logger->logconfess("Could not decode next_req json, error: $@") if $@;

        my @required_fields = qw/ method url /;

        defined $next_req->{$_} or $logger->logconfess("JSON does not have all the required fields.") for @required_fields;

        splice @headers, $next_req_index, $next_req_index + 1;
    }

    $self->logger->debug( join ' ', 'Appending', $row->{method}, $row->{url}, $row->{id}, 'to queue' );

    my $id = $async->add( HTTP::Request->new( uc $row->{method}, $row->{url}, \@headers, encode('utf8', $row->{body}) ) );
    $http_ids->{$id}{id}       = $row->{id};
    $http_ids->{$id}{time}     = time;
    $http_ids->{$id}{try}      = $row->{try_num};
    $http_ids->{$id}{next_req} = $next_req;

    return $id;
}

sub _set_request_status {
    my ( $self, %opts ) = @_;

    my $async = $self->ahttp;

    $self->schema->txn_do(
        sub {

            my $ref = $opts{ref};

            if ( $ref->{next_req} && $opts{res}->code =~ /^2/ ) {

                foreach my $k (keys %{ $ref->{next_req} } ) {
                    # Tratando requests com json

                    $ref->{next_req}->{$k} = encode_json( $ref->{next_req}->{$k} ) if ref $ref->{next_req}->{$k} eq 'HASH';
                }
				$self->logger->debug( 'next_req: ' .  %{ $ref->{next_req} } );

                my $next_req = $self->_http_request_rs->create( $ref->{next_req} );
				$self->logger->debug('next_req created, id: ' .  $next_req->id);
            }

            $self->_http_response_rs->create(
                {
                    http_request_id => $ref->{id},
                    try_num         => $ref->{try} + 1,
                    took            => ( time - $ref->{time} ) . ' seconds',
                    response        => $opts{res}->as_string
                }
            );

            $self->_http_request_status_rs->update_or_create(
                { done => $opts{res}->code =~ /^2/ ? 1 : 0, try_num => $ref->{try} + 1, http_request_id => $ref->{id} },
                { http_request_id => $ref->{id} }
            );

        }
    );

}

1;
