package Apokalo::API::Schedule;
use Moo;
use utf8;
use Apokalo::SchemaConnected;
use Apokalo::Logger;
use DateTime;
use Apokalo::API::Object::HTTPRequest;
use UUID::Tiny qw/is_uuid_string/;

has 'schema' => ( is => 'rw', lazy => 1, builder => \&GET_SCHEMA );
has '_http_request_rs' => (
    is      => 'rw',
    builder => sub {
        shift->schema->resultset('HttpRequest');
    }
);

sub add {
    my ( $self, %opts ) = @_;
    my $obj = Apokalo::API::Object::HTTPRequest->new(%opts);

    my $row = $self->_http_request_rs->create(
        {
            ( map { $_ => $obj->$_ } qw/method headers body url/ ),
            ( $obj->retry_each     ? ( retry_each     => $obj->retry_each . ' seconds' ) : () ),
            ( $obj->retry_exp_base ? ( retry_exp_base => $obj->retry_exp_base )          : () ),

            (
                $obj->retry_until ? ( retry_until => DateTime->from_epoch( epoch => $obj->retry_until )->datetime ) : ()
            ),
            ( $obj->wait_until ? ( wait_until => DateTime->from_epoch( epoch => $obj->wait_until )->datetime ) : () ),

        }
    );

    return $self->get( id => $row->id );
}

sub get {
    my ( $self, %opts ) = @_;
    die "Value \"{$opts{id}}\" did not pass UUID constraint\n" unless is_uuid_string $opts{id};

    my $row = $self->_http_request_rs->search(
        { id => $opts{id} },
        {
            join      => 'http_request_status',
            'columns' => [
                {
                    ( map { $_ => $_ } qw/body  headers id method retry_exp_base url / ),
                    ( map { $_ => \"EXTRACT(EPOCH FROM $_)::int" } qw/retry_each retry_until wait_until created_at/ ),
                    success => \'CASE WHEN (http_request_status.done) THEN TRUE ELSE FALSE END',
                    try_num => \
                      'CASE WHEN (http_request_status.try_num IS NULL) THEN  0 ELSE http_request_status.try_num END',
                }
            ],
            result_class => 'DBIx::Class::ResultClass::HashRefInflator'
        }
    )->next;
    return $row;
}

( ( $ENV{HARNESS_ACTIVE} || $0 =~ /forkprove/ ) ? do { &GET_SCHEMA } : 1 );
