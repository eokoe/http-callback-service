package Apokalo::API::Schedule;
use Moo;
use utf8;
use Apokalo::SchemaConnected;
use Apokalo::Logger;
use Apokalo::API::Object::HTTPRequest;
use UUID::Tiny qw/is_uuid_string/;

use File::Temp;
use Text::CSV;

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

            ( $obj->retry_until ? ( retry_until => \[ 'to_timestamp(?)', $obj->retry_until ] ) : () ),
            ( $obj->wait_until ? ( wait_until => \[ 'to_timestamp(?)',, $obj->wait_until ] ) : () ),

        }
    );

    return { id => $row->id };
}

sub add_bulk {
    my ($self, @items) = @_;

    $self->_http_request_rs->txn_do(
        sub {
            $self->_http_request_rs->populate([
                map {
                    my %opts = %{ $_ };
                    my $obj  = Apokalo::API::Object::HTTPRequest->new(%opts);

                    +{
                        ( map { $_ => $obj->$_ } qw/method headers body url/ ),
                        ( $obj->retry_each     ? ( retry_each     => $obj->retry_each . ' seconds' ) : () ),
                        ( $obj->retry_exp_base ? ( retry_exp_base => $obj->retry_exp_base          ) : () ),

                        ( $obj->retry_until ? ( retry_until => \[ 'TO_TIMESTAMP(?)', $obj->retry_until ] ) : () ),
                        ( $obj->wait_until  ? ( wait_until  => \[ 'TO_TIMESTAMP(?)', $obj->wait_until ] )  : () ),
                    }
                } @items
            ]);
        }
    )

    return { count => scalar(@items) };
}

sub get {
    my ( $self, %opts ) = @_;
    die "Value \"{$opts{id}}\" did not pass UUID constraint\n" unless is_uuid_string $opts{id};

    my $row = $self->_http_request_rs->search(
        { id => $opts{id} },
        {
            join      => { 'http_request_status' => 'http_response' },
            'columns' => [
                {
                    ( map { $_ => $_ } qw/body  headers id method retry_exp_base url / ),
                    (
                        map { $_ => \"EXTRACT(EPOCH FROM $_)::int" }
                          qw/retry_each retry_until wait_until me.created_at http_response.created_at/
                    ),
                    ( map { $_ => \"EXTRACT(EPOCH FROM $_)::numeric" } qw/http_response.took/ ),
                    success => \'CASE WHEN (http_request_status.done) THEN TRUE ELSE FALSE END',
                    try_num => \
                      'CASE WHEN (http_request_status.try_num IS NULL) THEN  0 ELSE http_request_status.try_num END',

                    'http_response.response' => 'http_response.response',

                }
            ],
            result_class => 'DBIx::Class::ResultClass::HashRefInflator'
        }
    )->next;
    $row->{$_} += 0 for qw/wait_until created_at response_took success try_num retry_each retry_until retry_exp_base/;

    if ( $row->{http_response} ) {
        $row->{http_response}{$_} += 0 for qw/created_at took/;
    }

    return $row;
}

( ( $ENV{HARNESS_ACTIVE} || $0 =~ /forkprove/ ) ? do { &GET_SCHEMA } : 1 );
