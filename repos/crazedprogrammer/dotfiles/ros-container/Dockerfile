FROM ubuntu:bionic

# Update timezone data
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive TZ=Europe/Amsterdam apt-get install -y tzdata

# Add ROS package repo
RUN apt-get install -y gnupg2 lsb-release \
    && sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' \
    && apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# Install all required packages
RUN [ "$(getent group users | cut -d: -f3)" = "100" ] \
    && apt-get update && apt-get -y install vim tmux htop mpv cppcheck valgrind doxygen usbutils sudo git ffmpeg wget \
         ttf-ubuntu-font-family qt5-default morse-simulator \
         libzbar-dev libpcl-dev libjpeg-turbo8-dev libturbojpeg0-dev libturbojpeg libglfw3-dev \
         libusb-1.0-0-dev libopenni2-dev opencl-headers openni2-utils \
         libjson-perl libperlio-gzip-perl \
         swig libusb-dev libreadline-dev libzzip-0-13 libavcodec-extra libssh-gcrypt-dev libzip-dev pbzip2 libpci-dev \
         ros-melodic-desktop-full ros-melodic-tf2-tools ros-melodic-webots-ros python-rospkg python-rospkg-modules

ARG INSTALL_WEBOTS=true
ARG WEBOTS_TAG=R2020a-rev1
RUN if [ "$INSTALL_WEBOTS" = true ]; then \
    cd /opt \
    && git clone --single-branch --branch "$WEBOTS_TAG" --recurse-submodules https://github.com/cyberbotics/webots.git \
    && cd /opt/webots \
    && rm -rf ./.git \
    && env HOME=/opt bash -c "source src/install_scripts/bashrc.linux && make release -j$(nproc)" \
    ; else true; fi
ENV WEBOTS_HOME=/opt/webots

ARG INSTALL_FREENECT2=false
ARG FREENECT2_TAG=master
RUN if [ "$INSTALL_FREENECT2" = true ]; then \
    cd /opt \
    && git clone --single-branch --branch "$FREENECT2_TAG" https://github.com/OpenKinect/libfreenect2.git \
    && cd libfreenect2 \
    && rm -rf ./.git \
    && mkdir build && cd build \
    && cmake .. -DBUILD_OPENNI2_DRIVER=ON -DBUILD_EXAMPLES=OFF -DCMAKE_INSTALL_PREFIX=/opt/freenect2 \
    && make -j$(nproc) \
    && make install \
    && cp /opt/libfreenect2/platform/linux/udev/90-kinect2.rules /etc/udev/rules.d/ \
    && ldconfig /opt/freenect2 \
    && ln -s /opt/libfreenect2/build/bin/Protonect /usr/local/bin/kinect_test \
    ; else true; fi

ARG INSTALL_LIBFRANKA=false
RUN if [ "$INSTALL_LIBFRANKA" = true ]; then \
    cd /opt \
    && git clone --recursive https://github.com/frankaemika/libfranka \
    && cd libfranka \
    && rm -rf ./.git \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=OFF -DBUILD_EXAMPLES=OFF .. \
    && cmake --build . \
    ; else true; fi

ARG INSTALL_LCOV=false
RUN if [ "$INSTALL_LCOV" = true ]; then \
    cd /tmp \
    && git clone https://github.com/linux-test-project/lcov.git \
    && cd lcov \
    && make install \
    ; else true; fi

# Install additional ROS SLAM packages
RUN sudo apt-get update && sudo apt-get install -y python-rosdep ros-melodic-hector-slam ros-melodic-gmapping ros-melodic-cartographer ros-melodic-slam-toolbox ros-melodic-slam-karto ros-melodic-amcl ros-melodic-mrpt-rbpf-slam ros-melodic-mrpt-ekf-slam-2d ros-melodic-mrpt-icp-slam-2d ros-melodic-rplidar-ros ros-melodic-cartographer-ros ros-melodic-laser-filters

# Remove temporary files
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add normal user
RUN useradd -m -u 1000 -g users -G dialout,sudo,tape -s /bin/bash casper; echo casper:casper | chpasswd
RUN echo "source /opt/bashrc.sh" >> /etc/bash.bashrc

# Install rust
RUN su casper -c "mkdir -p /home/casper/.cargo/registry"
VOLUME /home/casper/.cargo/registry
RUN su casper -c "export HOME=/home/casper; curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"

# Initialize rosdep
RUN rosdep init
RUN su casper -c "export HOME=/home/casper; rosdep update"

# Copy configuration files
COPY startup.sh /opt/startup.sh
COPY bashrc.sh /opt/bashrc.sh
COPY tmux.conf /etc/tmux.conf
RUN su casper -c "mkdir -p /home/casper/.config/Cyberbotics"
COPY --chown=casper:users Webots-R2020a.conf /home/casper/.config/Cyberbotics/Webots-R2020a.conf
RUN chmod 644 /home/casper/.config/Cyberbotics/Webots-R2020a.conf

ENTRYPOINT [ "/usr/bin/env", "bash", "/opt/startup.sh" ]

USER casper
WORKDIR /pwd
