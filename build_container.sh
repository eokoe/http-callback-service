#!/bin/bash
cp cpanfile docker/cpanfile_local
docker build -t eokoe/http-callback . -f docker/Dockerfile
