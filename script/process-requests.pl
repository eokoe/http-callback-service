#!/usr/bin/env perl
use strict;
use warnings;
use utf8;


use FindBin qw($Bin);
use lib "$Bin/../lib";
use Apokalo::SchemaConnected;
use Apokalo::Daemon::ProcessQueue;
use DDP;

my $schema = GET_SCHEMA( pg_advisory_lock => 1 );

my $daemon = Apokalo::Daemon::ProcessQueue->new( schema => $schema );

$daemon->listen_queue;

