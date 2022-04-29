#!/bin/bash -e


export USER=app

source /home/app/perl5/perlbrew/etc/bashrc

cd /tmp/

export MAKEFLAGS="-j 8"
cpanm -n . --installdeps -v
