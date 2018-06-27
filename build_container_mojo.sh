#!/bin/bash
cp cpanfile docker/cpanfile_local
docker build -t eokoe/http-callback docker/mojo