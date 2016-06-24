package Apokalo::API::Schedule;
use Moo;
use utf8;
use Apokalo::SchemaConnected;
use Apokalo::Logger;

use Types::Standard qw( Str Int );

has 'schema' => ( is => 'rw', lazy => 1, builder => \&GET_SCHEMA );
has '_http_request_rs' => (
    is      => 'rw',
    builder => sub {
        shift->schema->resultset('HttpRequest');
    }
);

sub add {


}

( ( $ENV{HARNESS_ACTIVE} || $0 =~ /forkprove/ ) ? do { &GET_SCHEMA } : 1 );
