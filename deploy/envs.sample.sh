#!/bin/bash

# $ cp envs.sample.sh envs_local.sh
# setup envs_local.sh
# $ HTTP_CB_ENV_FILE=deploy/envs_local.sh deploy/restart_services.sh
export GIT_DIR=$(git rev-parse --show-toplevel)

export PERLBREW_ROOT=/opt/perlbrew
source ${PERLBREW_ROOT}/etc/bashrc

# log directory
export HTTP_CB_LOG_DIR=$HOME/http-callback-logs

# git location
export HTTP_CB_APP_DIR=$GIT_DIR

# ports

export HTTP_CB_API_PORT=2626

export HTTP_CB_DB_HOST=localhost
export HTTP_CB_DB_PASS=no
export HTTP_CB_DB_PORT=5432
export HTTP_CB_DB_USER=postgres
export HTTP_CB_DB_NAME=httpcallback_dev
