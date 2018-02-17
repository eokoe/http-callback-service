#!/bin/bash
export PIDFILE=/tmp/start_server.pid;

cd /src;

MOJO_MODE=production MOJO_MAX_MESSAGE_SIZE=1073741824 LIBEV_FLAGS=4 MOJO_INACTIVITY_TIMEOUT=600 hypnotoad api-server

pgrep -f 'perl script/process-request' | xargs kill
