# HTTP callback service
This service is a simple way to make http callback with automatic retry and scheduling.

Speed is not a goal, as it will queue it on postgres and pull each second, but others jobs may be blocking processing.

It's intended to be used inside an secure network (as it does not have any authorization by now).

As a user, you may do an (guess what, http) request with, at least:

    method  = POST, GET, PUT or HEAD
    url     = http or https + host + (maybe a port) and path_query
    headers = Heahder: Value, add many using \n
    body    = anything goes (in reality utf8 text)

And if everything looks good, you receive an ID (and HTTP 200), where you can check it status later.

## Optional parameters

    wait_until        = unix-timestamp (UTC 0); default no waiting
    retry_until       = unix-timestamp (UTC 0); default 5 days
    retry_each        = in seconds; default 15
    retry_multiplier  = smallint (retry_multiplier * retry_each * try number); default 2

# Usage

linux with curl:

    curl -X POST http://127.0.0.1:2626/schedule?method=post&url=http%3a%2f%2fexemple.com%3ffoo%3dbar&headers=X-token%3a+100%0d%0ax-api-secret%3a+bar&body=HELO&secure=1

# Endpoints

    POST /schedule
    GET  /schedule/$UID

# Requirements

- perl 5.16 and newer
- postgres 9.1 and newer
- start-stop-daemon 1.17.5 and newer
- cpanm

> It's tested on ubuntu 14.04 LTS, but may work on lot of others linux distributions

# Configuration files

- **sqitch.conf**

    have the databae settings for the Sqitch (database versioning)

- **deploy/envs.sample.sh**

    have the default ENVs. Copy it to **deploy/envs_local.sh**; if you do that, run it before running anything

# Setup

Before starting the server, you need to configure the database.
If you need change database settings, edit on sqitch.conf

    createdb httpcallback_dev -h 127.0.0.1 -U postgres
    sqitch deploy -t local

## Installing modules deps

    cpanm --installdeps . # -n


## Starting / gracefully reloading

    HTTP_CB_ENV_FILE=deploy/env_local.sh deploy/restart_services.sh

> When HTTP_CB_DB_* is changed, you will need to run `fuser $HTTP_CB_API_PORT/tcp -k`. This is not gracefully, but needed as the server_starter fork don't get fresh ENV before starting the new code.

## Running tests

As fast as possible, hard to read output.

    forkprove -MApokalo::API::Schedule -lr -j 4 t/

Good speed vs readability

    DBIC_TRACE=1 TRACE=1 forkprove -MApokalo::API::Schedule -lvr -j 1 t/

Slower, but does not need forkprove

    prove -lvr t/

## TODO

- authorization
- way to configure when to delete requests from database
- .deb install?
- Use HTTP::Async instead of forks?
