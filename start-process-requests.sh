#!/bin/bash
cd /src;
source /home/app/perl5/perlbrew/etc/bashrc;
source envfile.sh
perl script/process-requests.pl 1>>/data/log/process-requests-daemon.log 2>>/data/log/process-requests-daemon.error.log
