FROM ros:melodic-robot

RUN [ "$(getent group users | cut -d: -f3)" = "100" ] \
    && apt-get update && apt-get -y install vim tmux htop mpv cppcheck valgrind doxygen \
         ros-melodic-ros-tutorials ros-melodic-rqt ros-melodic-rqt-common-plugins \
         ros-melodic-rviz ros-melodic-tf ros-melodic-tf2-tools ros-melodic-turtle-tf2 \
         libzbar-dev libpcl-dev libjpeg-turbo8-dev libturbojpeg0-dev libturbojpeg libglfw3-dev \
         libusb-1.0-0-dev usbutils sudo

RUN useradd -m -u 1000 -g users -G dialout,sudo,tape -s /bin/bash casper; echo casper:casper | chpasswd
RUN echo "source /opt/bashrc.sh" >> /etc/bash.bashrc

ADD startup.sh /opt/startup.sh
ADD bashrc.sh /opt/bashrc.sh
ADD tmux.conf /etc/tmux.conf

ENTRYPOINT [ "/usr/bin/env", "bash", "/opt/startup.sh" ]

USER casper
WORKDIR /pwd
