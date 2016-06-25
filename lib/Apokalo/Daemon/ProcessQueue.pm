package Apokalo::Daemon::ProcessQueue;
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

sub pending_jobs {
    my ( $self, %opts ) = @_;

    my @rows = $self->_http_request_rs->search(
        {
            '-or' => [
                { 'http_request_status.done' => undef },
                {
                    'http_request_status.done' => 0,

                    -and => [ \' wait_until + ( retry_exp_base ^ LEAST(http_request_status.try_num, 10) * retry_each) > now()' ],

                }
            ],
            wait_until  => { '<=' => \'now()' },
            retry_until => { '>=' => \'now()' },

        },
        {
            join      => 'http_request_status',
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

1;
