package Apokalo::API::Schedule;
use Moo;
use utf8;
use Apokalo::SchemaConnected;
use Apokalo::Logger;
use DateTime;
use Apokalo::API::Object::HTTPRequest;

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

    use DDP;
    p $obj->wait_until;
    my $row = $self->_http_request_rs->create(
        {
            ( map { $_ => $obj->$_ } qw/method headers body url/ ),
            ( $obj->retry_each       ? ( retry_each       => $obj->retry_each . ' seconds' ) : () ),
            ( $obj->retry_multiplier ? ( retry_multiplier => $obj->retry_multiplier )        : () ),

            (
                $obj->retry_until ? ( retry_until => DateTime->from_epoch( epoch => $obj->retry_until )->datetime ) : ()
            ),
            ( $obj->wait_until ? ( wait_until => DateTime->from_epoch( epoch => $obj->wait_until )->datetime ) : () ),

        }
    );

    return $row;
}

( ( $ENV{HARNESS_ACTIVE} || $0 =~ /forkprove/ ) ? do { &GET_SCHEMA } : 1 );
