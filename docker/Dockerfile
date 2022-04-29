FROM phusion/baseimage:focal-1.2.0

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
 && rm -rf /var/lib/apt/lists/* && apt-get clean

RUN useradd -ms /bin/bash app;
USER app

ADD docker/install-perlbrew.sh /tmp/install-perlbrew.sh
RUN /tmp/install-perlbrew.sh

USER root
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev zlib1g-dev libssl-dev \
 && rm -rf /var/lib/apt/lists/* && apt-get clean

USER app
ADD docker/install-cpan-modules.sh /tmp/install-cpan-modules.sh

RUN /tmp/install-cpan-modules.sh

USER root

RUN apt-get update && apt-get install -y \
    libpq-dev \
    postgresql-client \
 && rm -rf /var/lib/apt/lists/* && apt-get clean

ADD cpanfile /tmp/cpanfile
ADD docker/install-cpan-extra-modules.sh /tmp/install-cpan-extra-modules.sh
USER app
RUN /tmp/install-cpan-extra-modules.sh
USER root

RUN mkdir /etc/service/http-callback
COPY docker/http-callback.sh /etc/service/http-callback/run

RUN mkdir /etc/service/http-callback-process-requests
COPY docker/http-callback-process-requests.sh /etc/service/http-callback-process-requests/run
