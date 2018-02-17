#!/bin/bash -e
export WORKERS=1

source /home/app/perl5/perlbrew/etc/bashrc

mkdir -p /data/log/;

cd /src;
source envfile.sh

sqitch deploy -t $HTTP_CB_SQITCH_DEPLOY_NAME 2>>/data/log/starman.log 1>&2

MOJO_MODE=production MOJO_MAX_MESSAGE_SIZE=1073741824 LIBEV_FLAGS=4 MOJO_INACTIVITY_TIMEOUT=600 hypnotoad api-server

