#!/usr/bin/perl

package APIServer;
use strict;
use warnings;
use JSON;
use Web::Simple;
use lib 'lib';
use Apokalo::API::Schedule;

no warnings 'uninitialized';
my $api = Apokalo::API::Schedule->new;

sub dispatch_request {

    sub (POST + /schedule + ?* + %*) {
        my ( $self, $get_params, $body_params, $env ) = @_;

        $get_params = { %{ $get_params || {} }, %{ $body_params || {} } };

        my $code = 201;
        my $ret = eval { $api->add(%$get_params) };
        if ($@) {
            $code = 400;
            my $err_msg = ref $@ eq 'Error::TypeTiny::Assertion' ? $@->message : "$@";
            chomp $err_msg;
            $err_msg =~ s/ at .+//;
            $err_msg =~ s/\(in.+args.+\{(.+)\}.+/on param $1/;

            $ret = { error => $err_msg };
        }

        return [
            $code,
            [
                'Content-Type' => 'application/json',
                ( $code == 201 ? ( 'Location' => '/schedule/' . $ret->{id} ) : () )
            ],
            [ encode_json($ret) ],
        ];
      }, sub (GET + /schedule/*) {
        my ( $self, $id, $env ) = @_;

        my $code = 200;
        my $ret = eval { $api->get( id => $id ) };
        if ($@) {
            $code = 400;
            my $err_msg = ref $@ eq 'Error::TypeTiny::Assertion' ? $@->message : "$@";
            chomp $err_msg;
            $err_msg =~ s/ at .+//;
            $err_msg =~ s/\(in.+args.+\{(.+)\}.+/on param $1/;

            $ret = { error => $err_msg };
        }

        return [ 404, [ 'Content-Type' => 'application/json' ], [ encode_json( {error => 'Object not found'} ) ] ]
          if !$ret;

        return [ $code, [ 'Content-Type' => 'application/json' ], [ encode_json($ret) ], ];
      }, sub (/schedule/...) {
        [ 405, [ 'Content-Type' => 'application/json' ], [ encode_json( {error => 'Method not allowed'} ) ] ];
      }, sub () {
        [ 404, [ 'Content-Type' => 'application/json' ], [ encode_json( {error => 'Page not found'} ) ] ];
      }
}

APIServer->run_if_script;
