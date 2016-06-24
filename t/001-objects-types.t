use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Apokalo::API::Object::HTTPRequest' }

eval {
    Apokalo::API::Object::HTTPRequest->new(

        method           => 'get',
        headers          => "Foo: bar\nFoo-www: 22",
        url              => 'http://exemple.com:8080?aa',
        retry_each       => 22,
        retry_multiplier => 1.24,
        wait_until       => time
    );
};
is $@, '', 'no error';
eval {
    Apokalo::API::Object::HTTPRequest->new(

        method => 'get',
        url    => 'http://exemple.com?sss=2'
    );
};
is $@, '', 'no error';

eval {
    Apokalo::API::Object::HTTPRequest->new(

        method           => 'get',
        headers          => 'Foo: bar',
        url              => 'http://exemple.com',
        retry_each       => 22,
        retry_multiplier => -1.24
    );
};
ok( $@, "error on negative retry_multiplier" );

eval {
    Apokalo::API::Object::HTTPRequest->new(

        method  => 'options',
        headers => 'Foo: bar',
        url     => 'http://exemple.com'
    );
};
ok( $@, "error on method options" );

eval {
    Apokalo::API::Object::HTTPRequest->new(

        method     => 'options',
        headers    => 'Foo: bar',
        url        => 'http://exemple.com',
        wait_until => -100,
    );
};
ok( $@, "error on negative wait_until" );

done_testing();
