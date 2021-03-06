#!/bin/bash

[ -z "$HTTP_CB_ENV_FILE" ] && echo "Need to set HTTP_CB_ENV_FILE env before run this." && exit 1;


source $HTTP_CB_ENV_FILE


if /bin/fuser $HTTP_CB_API_PORT/tcp ; then
    echo "http callback is running"
else
    cd $HTTP_CB_APP_DIR;

    HTTP_CB_ENV_FILE=deploy/envs.sh ./deploy/restart_services.sh
fi

cd $HTTP_CB_APP_DIR/script
# WOKRERS
./process-requests start

