#!/bin/bash

[ -z "$HTTP_CB_ENV_FILE" ] && echo "Need to set HTTP_CB_ENV_FILE env before run this." && exit 1;


source $HTTP_CB_ENV_FILE

mkdir -p $HTTP_CB_LOG_DIR

STARMAN_BIN="$(which starman)"
DAEMON="$(which start_server)"

line (){
    perl -e "print '-' x 40, $/";
}

up_server (){
    TYPE=api
    PSGI_APP_NAME="$1"
    PORT="$2"
    WORKERS=$3

    ERROR_LOG="$HTTP_CB_LOG_DIR/$TYPE.error.log"
    STATUS="$HTTP_CB_LOG_DIR/$TYPE.start_server.status"
    PIDFILE="$HTTP_CB_LOG_DIR/$TYPE.start_server.pid"
    APP_DIR="$HTTP_CB_APP_DIR/"

    touch $ERROR_LOG
    touch $PIDFILE
    touch $STATUS

    STARMAN="$STARMAN_BIN -I$APP_DIR/lib --preload-app --workers $WORKERS --error-log $ERROR_LOG.starman $APP_DIR/$PSGI_APP_NAME"

    DAEMON_ARGS=" --pid-file=$PIDFILE --signal-on-hup=QUIT --status-file=$STATUS --port 0.0.0.0:$PORT -- $STARMAN"

    echo "Restarting $TYPE...  $DAEMON --restart $DAEMON_ARGS"
    $DAEMON --restart $DAEMON_ARGS

    if [ $? -gt 0 ]; then
        echo "Restart failed, application likely not running. Starting..."

        /sbin/start-stop-daemon -b --start --pidfile $PIDFILE --chuid $USER --chdir $APP_DIR -u $USER --exec $DAEMON --$DAEMON_ARGS

    fi
}

cd $HTTP_CB_APP_DIR;
cpanm -n --installdeps .;

cd $HTTP_CB_APP_DIR;
sqitch deploy -t $HTTP_CB_SQITCH_DEPLOY_NAME

up_server "api-server.psgi" $HTTP_CB_API_PORT $HTTP_CB_API_WORKERS

line

echo "Restarting scripts...";

cd $HTTP_CB_APP_DIR/script

# WOKRERS

./process-requests restart
line
echo "Sleeping... Check if is running";
sleep 2

./process-requests status
