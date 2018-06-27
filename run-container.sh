#!/bin/bash

# arquivo de exemplo para iniciar o container
export SOURCE_DIR="$HOME/projects/http-callback-service/"
export DATA_DIR='/tmp/htpp-callback-data/'

mkdir -p $DATA_DIR

# confira o seu ip usando ifconfig docker0|grep 'inet addr:'
export DOCKER_LAN_IP=172.17.0.1

# porta que será feito o bind
export LISTEN_PORT=2049

docker run --name http-callback \
 -v $SOURCE_DIR:/src -v $DATA_DIR:/data \
 -p $DOCKER_LAN_IP:$LISTEN_PORT:2626 \
 --cpu-shares=512 \
 --memory 1800m -d --restart unless-stopped eokoe/http-callback
