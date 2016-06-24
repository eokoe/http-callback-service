use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Apokalo::SchemaConnected' }

BEGIN { use_ok 'Apokalo::API::Schedule' }

my $api = Apokalo::API::Schedule->new;

eval {
    $api->schema->txn_do(
        sub {

            my $row = $api->add(

                method           => 'get',
                headers          => "Foo: bar\nFoo-www: 22",
                url              => 'http://exemple.com:8080?aa',
                retry_each       => 22,
                retry_multiplier => 1.24,
                wait_until       => time
            );

            is( $api->_http_request_rs->count, '1', 'good, one line inserted!' );
            is( $row->{url}, 'http://exemple.com:8080?aa', 'url looks good' );

            is( $row->{retry_each}, '22', 'retry_each looks good' );

            my $row2 = $api->get( id => $row->{id});

            is_deeply($row2, $row, 'same add and get return same struct');
            eval{$api->get( id => 'asdas')};
            ok($@, 'invalid id ' . $@);
            die 'rollback';
        }
    );
};

die $@ unless $@ =~ /rollback/;

done_testing();
