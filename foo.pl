#!/usr/bin/perl

use strict;
use warnings;
use JSON;

use lib 'lib';
use Apokalo::SchemaConnected;
use DDP;
my $timeout=4;
my $fo;
use Time::Out qw(timeout) ;


 timeout 5 => sub {
    # your code goes were and will be interrupted if it runs
    # for more than $nb_secs seconds.
    $fo = GET_SCHEMA( pg_advisory_lock => 1 );
  } ;
  if ($@){
    # operation timed-out
  }


if ($@) {
    die $@ unless $@ eq "alarm\n";               # propagate unexpected errors

    print STDERR "already locked...";
    exit;
}

while (1) {
    p $fo->resultset('HttpRequest')->count;
    sleep 10;
}
