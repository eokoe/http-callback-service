#!/bin/bash -e
source /home/app/perl5/perlbrew/etc/bashrc

mkdir -p /data/log/;

cd /src;
source envfile.sh

sqitch deploy -t $HTTP_CB_SQITCH_DEPLOY_NAME 2>>/data/log/starman.log 1>&2

LIBEV_FLAGS=4 hypnotoad api-server

sleep infinity
