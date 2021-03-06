use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Apokalo::SchemaConnected' }
BEGIN { use_ok 'Apokalo::API::Schedule' }
BEGIN { use_ok 'Apokalo::Daemon::ProcessQueue' }

my $api = Apokalo::API::Schedule->new;

my $daemon = Apokalo::Daemon::ProcessQueue->new( schema => $api->schema );

eval {
    $api->schema->txn_do(
        sub {

            my $row = $api->add(

                method         => 'get',
                headers        => "Foo: bar\nFoo-www: 22",
                url            => 'http://exemple.com:8080?aa',
                retry_each     => 22,
                retry_exp_base => 1.24,
                wait_until     => time
            );

            is( $api->_http_request_rs->count, '1', 'good, one line inserted!' );

            my @pen = $daemon->pending_jobs;
            if ( is( scalar @pen, 1, 'has pending jobs' ) ) {

                my @pen = $daemon->pending_jobs( id_not_in => [ $pen[0]{id} ] );
                is( scalar @pen, 0, 'id_not_in option working' );
            }

            die 'rollback';
        }
    );
};

die $@ unless $@ =~ /rollback/;

done_testing();
