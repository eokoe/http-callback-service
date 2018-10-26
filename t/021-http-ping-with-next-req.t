use strict;
use warnings;

use Test::More;
use HTTP::Response;
use Test::Fake::HTTPD;

BEGIN { use_ok 'Apokalo::SchemaConnected' }
BEGIN { use_ok 'Apokalo::API::Schedule' }
BEGIN { use_ok 'Apokalo::Daemon::ProcessQueue' }

my $api = Apokalo::API::Schedule->new;

my $httpd = Test::Fake::HTTPD->new( timeout => 5, );

$httpd->run(
    sub {
        my $req = shift;
        return [ 200, [ 'Content-Type' => 'text/plain' ], ['Hello World'] ];
    }
);

my $daemon = Apokalo::Daemon::ProcessQueue->new( schema => $api->schema );

eval {
    $api->schema->txn_do(
        sub {

            is( $daemon->run_once, -2, 'no processes in queue' );
            my $row = $api->add(

                method         => 'get',
                headers        => "Foo: bar\nFoo-www: 22\n" . 'next-req: {"url": "www.foobar.foo", "method": "get"}',
                url            => $httpd->endpoint . '/',
                retry_each     => 22,
                retry_exp_base => 1.24,
                wait_until     => time
            );

            is( $api->_http_request_rs->count, '1', 'good, one line inserted!' );

            is( $daemon->run_once, 1, 'processed' );

            my @pen = $daemon->pending_jobs;
            is( scalar @pen, 1, 'one pending_jobs' );

            die 'rollback';
        }
    );
};

die $@ unless $@ =~ /rollback/;

done_testing();
