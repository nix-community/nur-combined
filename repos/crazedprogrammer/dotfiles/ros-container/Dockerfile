FROM ros:melodic-robot

RUN apt-get update && apt-get -y install vim ros-melodic-ros-tutorials ros-melodic-rqt ros-melodic-rqt-common-plugins \
    && [ "$(getent group users | cut -d: -f3)" = "100" ] \
    && useradd -m -u 1000 -g users -s /bin/bash casper
RUN apt-get -y install tmux htop
RUN echo "source /opt/bashrc.sh" >> /etc/bash.bashrc

ADD startup.sh /opt/startup.sh
ADD bashrc.sh /opt/bashrc.sh
ADD tmux.conf /etc/tmux.conf

ENTRYPOINT [ "/usr/bin/env", "bash", "/opt/startup.sh" ]

USER casper
WORKDIR /pwd
