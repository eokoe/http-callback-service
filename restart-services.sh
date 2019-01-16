#!/bin/bash
export PIDFILE=/tmp/start_server.pid;

cd /src;

LIBEV_FLAGS=4 hypnotoad api-server

pgrep -f 'perl script/process-request' | xargs kill
