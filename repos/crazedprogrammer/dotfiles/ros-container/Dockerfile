FROM osrf/ros:melodic-desktop-full

ARG FREENECT2_TAG=false

RUN [ "$(getent group users | cut -d: -f3)" = "100" ] \
    && apt-get update && apt-get -y install vim tmux htop mpv cppcheck valgrind doxygen usbutils sudo \
         libzbar-dev libpcl-dev libjpeg-turbo8-dev libturbojpeg0-dev libturbojpeg libglfw3-dev \
         libusb-1.0-0-dev libopenni2-dev opencl-headers openni2-utils \
         ros-melodic-tf2-tools libjson-perl libperlio-gzip-perl
RUN apt-get update && apt-get -y install ttf-ubuntu-font-family qt5-default

RUN cd /root \
    && git clone https://github.com/OpenKinect/libfreenect2.git \
    && cd libfreenect2 \
    && /bin/bash -c "if ! [[ $FREENECT2_TAG == false ]]; then git checkout tags/$FREENECT2_TAG; fi" \
    && mkdir build && cd build \
    && cmake .. -DBUILD_OPENNI2_DRIVER=ON -DBUILD_EXAMPLES=OFF -DCMAKE_INSTALL_PREFIX=/root/freenect2 \
    && make -j$(nproc) \
    && make install \
    && cp /root/libfreenect2/platform/linux/udev/90-kinect2.rules /etc/udev/rules.d/ \
    && ldconfig /root/freenect2 \
    && ln -s /root/libfreenect2/build/bin/Protonect /usr/local/bin/kinect_test

RUN cd /root \
    && git clone --recursive https://github.com/frankaemika/libfranka \
    && cd libfranka \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=OFF -DBUILD_EXAMPLES=OFF .. \
    && cmake --build .

RUN cd /root \
    && git clone https://github.com/linux-test-project/lcov.git \
    && cd lcov \
    && make install

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN chmod 777 /root

RUN useradd -m -u 1000 -g users -G dialout,sudo,tape -s /bin/bash casper; echo casper:casper | chpasswd
RUN echo "source /opt/bashrc.sh" >> /etc/bash.bashrc

COPY startup.sh /opt/startup.sh
COPY bashrc.sh /opt/bashrc.sh
COPY tmux.conf /etc/tmux.conf

ENTRYPOINT [ "/usr/bin/env", "bash", "/opt/startup.sh" ]

USER casper
WORKDIR /pwd
