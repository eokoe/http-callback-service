# HTTP callback service:
This service is a small but stable way to make http callback.

It's intended to be used inside an secure network (as it does not have any authorization by now)

As a user, you may do an (guess what, http) request with, at least:

    method  = POST, GET, PUT or HEAD
    url     = scheme, host, port and path_query
    headers = Heahder: Value, add many using \n
    body    = anything goes (in reality utf8 text)
    secure => false if host does not support https.

And if everything looks good, you receive an ID, where you can check it status later.

# Usage:

curl:

    curl http://127.0.0.1:2626/schedule?method=post&url=http%3a%2f%2fexemple.com%3ffoo%3dbar&headers=X-token%3a+100%0d%0ax-api-secret%3a+bar&body=HELO&secure=1


# Requirements:

- perl 5.16 and newer
- postgres 9.1 and newer
- start-stop-daemon 1.17.5 and newer
- cpanm

> It's tested on ubuntu 14.04 LTS, but may work in a lot of others linux distributions

# Configuration files:

sqitch.conf have the databae settings for the Sqitch (database versioning)
deploy/envs.sample.sh has the default ENVs that the system uses. Copy or rename it to deploy/envs_local.sh and run-it before running anything that's not default.

# Setup:

Before starting the server, you need to configure the database.
If you need change database settings, edit on sqitch.conf

    createdb httpcallback_dev -h 127.0.0.1 -U postgres
    sqitch deploy -t local


Gracefully reloading or starting:

HTTP_CB_ENV=deploy/env_local.sh deploy/restart_services.sh

> if changed envs_local.sh postgres configuration, you will need to `fuser 2626/tcp -k`, not gracefully, as the server_starter fork doesn't get fresh envs before starting the new code.
