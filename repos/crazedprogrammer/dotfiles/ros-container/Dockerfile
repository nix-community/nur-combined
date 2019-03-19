FROM ros:melodic-robot

RUN [ "$(getent group users | cut -d: -f3)" = "100" ] \
    && apt-get update && apt-get -y install vim tmux htop cppcheck valgrind doxygen \
         ros-melodic-ros-tutorials ros-melodic-rqt ros-melodic-rqt-common-plugins
RUN apt-get update; apt-get -y install mpv ros-melodic-rviz
RUN useradd -m -u 1000 -g users -G dialout,sudo,tape -s /bin/bash casper
RUN echo "source /opt/bashrc.sh" >> /etc/bash.bashrc

ADD startup.sh /opt/startup.sh
ADD bashrc.sh /opt/bashrc.sh
ADD tmux.conf /etc/tmux.conf

ENTRYPOINT [ "/usr/bin/env", "bash", "/opt/startup.sh" ]

USER casper
WORKDIR /pwd
