#!/bin/bash -e


export USER=app

source /home/app/perl5/perlbrew/etc/bashrc

cd /tmp/

export MAKEFLAGS="-j 8"
cpanm -nv Furl \
    Server::Starter \
    Moo \
    Log::Log4perl \
    DBIx::Class::InflateColumn::DateTime \
    Web::Simple \
    Type::Tiny \
    UUID::Tiny \
    Data::Validate::URI \
    Starman \
    Server::Starter \
    Net::Server::SS::PreFork \
    HTTP::Async \
    Daemon::Control