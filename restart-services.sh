#!/bin/bash
export PIDFILE=/tmp/start_server.pid;

cd /src;
if [ -e "$PIDFILE" ]; then
    kill -HUP $(cat $PIDFILE)
fi

pgrep -f 'perl script/process-request' | xargs kill
