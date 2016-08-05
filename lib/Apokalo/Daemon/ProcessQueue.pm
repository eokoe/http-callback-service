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

has 'schema' => ( is => 'rw', lazy => 1, builder => \&GET_SCHEMA );
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
    HTTP::Async->new;
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
                        \' wait_until + ( retry_exp_base ^ LEAST(http_request_status.try_num, 10) * retry_each) > now()'
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
            rows => $opts{rows} ? $opts{rows} : 10,
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

    $self->_self_add($pending);

    if ( $async->not_empty ) {
        if ( my ( $response, $iid ) = $async->wait_for_next_response(30) ) {

            # deal with $response
            $self->_mark_done( res => $response, ref => $http_ids->{$iid} );
            return 1;
        }
        else {
            return -1;
        }
    }

    return -2;
}

sub _self_add {
    my ( $self, $row ) = @_;
    my @headers = map { split /:\s+/, $_, 2 } split /\n/, $row->{headers};
    my $async = $self->ahttp;

    my $id = $async->add( HTTP::Request->new( uc $row->{method}, $row->{url}, \@headers, $row->{body} ) );
    $http_ids->{$id}{id}   = $row->{id};
    $http_ids->{$id}{time} = time;
    $http_ids->{$id}{try}  = $row->{try_num};

    return $id;
}

sub _mark_done {
    my ( $self, %opts ) = @_;

    $self->schema->txn_do(
        sub {

            my $ref = $opts{ref};

            my $request_status =
              $self->_http_request_status_rs->update_or_create(
                { done => $opts{res}->is_success, try_num => $ref->{try} + 1, http_request_id => $ref->{id} },
                { http_request_id => $ref->{id} } );

            $self->_http_response_rs->create(
                {
                    http_request_id => $ref->{id},
                    try_num         => $ref->{try} + 1,
                    took            => ( time - $ref->{time} ) . ' seconds',
                    response        => $opts{res}->as_string
                }
            );

        }
    );

}

1;
