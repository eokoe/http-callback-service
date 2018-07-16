#!/bin/bash -e
#source /home/app/perl5/perlbrew/etc/bashrc

#mkdir -p /data/log/;

#cd /src;
source envfile.sh

#sqitch deploy -t $HTTP_CB_SQITCH_DEPLOY_NAME 2>>/data/log/starman.log 1>&2

echo $(test -z "$HTTP_CB_USE_MOJO");

if [ -z "$HTTP_CB_USE_MOJO" ]; then
    start_server \
    --pid-file=/tmp/start_server.pid \
    --signal-on-hup=QUIT \
    --kill-old-delay=10 \
    --port=$HTTP_CB_API_PORT \
    -- starman \
    -I/src/lib \
    --workers $HTTP_CB_API_WORKERS \
    --error-log /data/log/starman.log \
    --user app --group app api-server.psgi
else
    MOJO_MODE=production MOJO_MAX_MESSAGE_SIZE=1073741824 LIBEV_FLAGS=4 MOJO_INACTIVITY_TIMEOUT=600 hypnotoad api-server
fi
