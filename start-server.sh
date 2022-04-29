#!/bin/bash -e
export API_WORKERS="${API_WORKERS:-1}"

source /home/app/perl5/perlbrew/etc/bashrc

mkdir -p /data/log/;

cd /src;
source envfile.sh

sqitch deploy -t $HTTP_CB_SQITCH_DEPLOY_NAME 2>>/data/log/starman.log 1>&2

start_server \
  --pid-file=/tmp/start_server.pid \
  --signal-on-hup=QUIT \
  --kill-old-delay=10 \
  --port=8080 \
  -- starman \
  -I/src/lib \
  --workers $API_WORKERS \
  --error-log /data/log/starman.log \
  --user app --group app api-server.psgi
