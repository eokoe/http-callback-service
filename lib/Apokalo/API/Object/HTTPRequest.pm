package Apokalo::API::Object::HTTPRequest;
use Moo;
use utf8;

use Types::Standard qw( Str Num Int Bool );
use Type::Utils qw( declare as where inline_as coerce from );

use Data::Validate::URI qw(is_http_uri is_https_uri);

my $HTTP_METHOD_STR = declare as Str, where { $_ =~ /^(GET|POST|PUT|HEAD)$/io };
coerce $HTTP_METHOD_STR, from Str, q{ uc $_ };

my $HTTP_URL_STR = declare as Str, where { is_http_uri($_) || is_https_uri($_) };

my $SmallInt = declare as Int, where { $_ > 0 && $_ < 32767 };
my $SmallNum = declare as Num, where { $_ > 0 && $_ < 32767 };

my $PositiveInt = declare
  as Int,
  where { $_ > 0 },
  inline_as { "$_ =~ /^[0-9]+\$/ and $_ > 0" };

my $HTTP_HEADER_STR = declare as Str, where {
    my @lines = split /\n/, $_;
    my $fail = 0;
    for (@lines) { next unless $_; $fail++ unless $_ =~ /^[^:]+:.+$/o }
    return !$fail;
};

has 'method' => (
    is       => 'ro',
    isa      => $HTTP_METHOD_STR,
    required => 1,
);

has 'url' => (
    required => 1,
    isa      => $HTTP_URL_STR,
    is       => 'ro',
);

has 'headers' => (
    is       => 'ro',
    isa      => $HTTP_HEADER_STR,
);

has 'body' => (
    is  => 'ro',
    isa => Str,
);

has 'retry_until' => (
    is  => 'ro',
    isa => $PositiveInt
);

has 'wait_until' => (
    is  => 'ro',
    isa => $PositiveInt
);

has 'retry_each' => (
    is  => 'ro',
    isa => $SmallInt
);

has 'retry_exp_base' => (
    is  => 'ro',
    isa => $SmallNum
);

1;
