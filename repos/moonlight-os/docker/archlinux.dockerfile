# syntax=docker/dockerfile:1
# artifacts: true
# platforms: linux/amd64
# archlinux does not have an arm64 base image
# no-cache-filters: artifacts,helios
ARG BASE=archlinux/archlinux
ARG TAG=base-devel
FROM ${BASE}:${TAG} AS helios-base

# Update keyring to avoid signature errors, and update system
RUN <<_DEPS
#!/bin/bash
set -e
pacman -Syy --disable-download-timeout --needed --noconfirm \
  archlinux-keyring
pacman -Syu --disable-download-timeout --noconfirm
pacman -Scc --noconfirm
_DEPS

FROM helios-base AS helios-deps

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install dependencies first - this layer will be cached
RUN <<_SETUP
#!/bin/bash
set -e

# Setup builder user, arch prevents running makepkg as root
useradd -m builder
echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# patch the build flags
# shellcheck disable=SC2016
sed -i 's,#MAKEFLAGS="-j2",MAKEFLAGS="-j$(nproc)",g' /etc/makepkg.conf

# install dependencies
pacman -Syu --disable-download-timeout --needed --noconfirm \
  base-devel \
  cmake \
  cuda \
  git \
  namcap \
  xorg-server-xvfb
pacman -Scc --noconfirm
_SETUP

FROM helios-deps AS helios-build

ARG BRANCH
ARG BUILD_VERSION
ARG COMMIT
ARG CLONE_URL
# note: BUILD_VERSION may be blank

ENV BRANCH=${BRANCH}
ENV BUILD_VERSION=${BUILD_VERSION}
ENV COMMIT=${COMMIT}
ENV CLONE_URL=${CLONE_URL}

# PKGBUILD options
ENV _use_cuda=true
ENV _run_unit_tests=true
ENV _support_headless_testing=true

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup builder user
USER builder

# copy repository
WORKDIR /build/helios/
COPY --link .. .

# setup build directory
WORKDIR /build/helios/build

# configure PKGBUILD file
RUN <<_MAKE
#!/bin/bash
set -e

sub_version=""
if [[ "${BRANCH}" != "master" ]]; then
  sub_version=".r${COMMIT}"
fi

cmake \
  -DSUNSHINE_CONFIGURE_ONLY=ON \
  -DSUNSHINE_CONFIGURE_PKGBUILD=ON \
  -DSUNSHINE_SUB_VERSION="${sub_version}" \
  /build/helios
_MAKE

WORKDIR /build/helios/pkg
RUN <<_PACKAGE
mv /build/helios/build/PKGBUILD .
mv /build/helios/build/helios.install .
makepkg --printsrcinfo > .SRCINFO
_PACKAGE

# create a PKGBUILD archive
USER root
RUN <<_REPO
#!/bin/bash
set -e
tar -czf /build/helios/helios.pkg.tar.gz .
_REPO

# namcap and build PKGBUILD file
USER builder
RUN <<_PKGBUILD
#!/bin/bash
set -e
# shellcheck source=/dev/null
source /etc/profile  # ensure cuda is in the PATH
export DISPLAY=:1
Xvfb ${DISPLAY} -screen 0 1024x768x24 &
namcap -i PKGBUILD
makepkg -si --noconfirm
rm -f /build/helios/pkg/helios-debug*.pkg.tar.zst
ls -a
_PKGBUILD

FROM helios-base AS helios

COPY --link --from=helios-build /build/helios/pkg/helios*.pkg.tar.zst /helios.pkg.tar.zst

# artifacts to be extracted in CI
COPY --link --from=helios-build /build/helios/pkg/helios*.pkg.tar.zst /artifacts/helios.pkg.tar.zst
COPY --link --from=helios-build /build/helios/helios.pkg.tar.gz /artifacts/helios.pkg.tar.gz

# install helios
RUN <<_INSTALL_HELIOS
#!/bin/bash
set -e
pacman -U --disable-download-timeout --needed --noconfirm \
  /helios.pkg.tar.zst
pacman -Scc --noconfirm
_INSTALL_HELIOS

# network setup
EXPOSE 47984-47990/tcp
EXPOSE 48010
EXPOSE 47998-48000/udp

# setup user
ARG PGID=1000
ENV PGID=${PGID}
ARG PUID=1000
ENV PUID=${PUID}
ENV TZ="UTC"
ARG UNAME=lizard
ENV UNAME=${UNAME}

ENV HOME=/home/$UNAME

# setup user
RUN <<_SETUP_USER
#!/bin/bash
set -e
groupadd -f -g "${PGID}" "${UNAME}"
useradd -lm -d ${HOME} -s /bin/bash -g "${PGID}" -u "${PUID}" "${UNAME}"
mkdir -p ${HOME}/.config/helios
ln -s ${HOME}/.config/helios /config
chown -R ${UNAME} ${HOME}
_SETUP_USER

USER ${UNAME}
WORKDIR ${HOME}

# entrypoint
ENTRYPOINT ["/usr/bin/helios"]
