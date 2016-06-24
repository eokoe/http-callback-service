use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Apokalo::SchemaConnected' }

BEGIN { use_ok 'Apokalo::API::Schedule' }

my $api = Apokalo::API::Schedule->new;

eval {
    $api->schema->txn_do(
        sub {

            $api->add(

                method           => 'get',
                headers          => "Foo: bar\nFoo-www: 22",
                url              => 'http://exemple.com:8080?aa',
                retry_each       => 22,
                retry_multiplier => 1.24,
                wait_until       => time
            );

            ok( my $row = $api->_http_request_rs->next, 'good, one line inserted!' );
            is( $row->url, 'http://exemple.com:8080?aa', 'url looks good' );

            is( $row->retry_each, '00:00:22', 'retry_each looks good' );

            die 'rollback';
        }
    );
};

die $@ unless $@ =~ /rollback/;

done_testing();
