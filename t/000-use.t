use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Apokalo::SchemaConnected' }

BEGIN { use_ok 'Apokalo::API::Schedule' }

my $api = Apokalo::API::Schedule->new;

is($api->_http_request_rs->count, '0', 'good, running tests on a empty database!');

done_testing();
