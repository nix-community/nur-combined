FROM ros:melodic-robot

RUN apt-get update && apt-get -y install vim \
    && [ "$(getent group users | cut -d: -f3)" = "100" ] \
    && useradd -m -u 1000 -g users -s /bin/bash casper

USER casper
WORKDIR /pwd
