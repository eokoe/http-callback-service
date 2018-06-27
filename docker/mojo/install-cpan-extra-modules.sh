#!/bin/bash -e


export USER=app

source /home/app/perl5/perlbrew/etc/bashrc

cd /tmp/

cpanm -n Catalyst::Plugin::I18N \
CatalystX::Eta \
Crypt::PRNG \
Daemon::Control \
DBD::Pg \
DBIx::Class \
DBIx::Class::InflateColumn::Serializer \
Lazy::Lockfile \
Log::Log4perl \
Net::Amazon::S3 \
Net::Flotum \
Net::Server::SS::PreFork \
Parallel::Prefork::SpareWorkers \
Server::Starter \
Starman \
Try::Tiny \
Try::Tiny::Retry \
WebService::Slack::IncomingWebHook \
Yaadgom \
Digest::MD5 \
FindBin \
FindBin::libs \
Furl \
MooseX::NonMoose \
MooseX::Singleton \
MooseX::Types::UUID

cpanm . --installdeps
