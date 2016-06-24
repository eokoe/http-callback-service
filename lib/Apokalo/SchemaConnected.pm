package Apokalo::SchemaConnected;
use strict;
use utf8;

use Apokalo::Logger;
require Exporter;

our @ISA = qw(Exporter);

our @EXPORT = qw(GET_SCHEMA);

sub GET_SCHEMA {

    log_info "require Apokalo::Schema...";
    require Apokalo::Schema;

    # database
    my $db_host = $ENV{HTTP_CB_DB_HOST} || 'localhost';
    my $db_pass = $ENV{HTTP_CB_DB_PASS} || 'no-password';
    my $db_port = $ENV{HTTP_CB_DB_PORT} || '5432';
    my $db_user = $ENV{HTTP_CB_DB_USER} || 'postgres';
    my $db_name = $ENV{HTTP_CB_DB_NAME} || 'httpcallback_dev';

    Apokalo::Schema->connect(
        "dbi:Pg:host=$db_host;port=$db_port;dbname=$db_name",
        $db_user, $db_pass,
        {
            "AutoCommit"     => 1,
            "quote_char"     => "\"",
            "name_sep"       => ".",
            "pg_enable_utf8" => 1,
            "on_connect_do"  => "SET client_encoding=UTF8; SET timezone = 'UTC';"
        }
    );

}

1;
