FROM ubuntu:22.04
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV EDITOR=vim

RUN apt-get update && \
    apt-get install --yes \
        ca-certificates \
        bash-completion \
        build-essential \
        curl \
        cmake \
        gnupg \
        htop \
        jq \
        less \
        lsb-release \
        lsof \
        man-db \
        nano \
        ssl-cert \
        sudo \
        unzip \
        xz-utils \
        zip

# install nix
RUN sh <(curl -L https://nixos.org/nix/install) --daemon

RUN mkdir -p $HOME/.config/nix $HOME/.config/nixpkgs && \
    echo 'sandbox = false' >> $HOME/.config/nix/nix.conf && \
    echo '{ allowUnfree = true; }' >> $HOME/.config/nixpkgs/config.nix && \
    echo '. $HOME/.nix-profile/etc/profile.d/nix.sh' >> $HOME/.bashrc

# install docker and configure daemon to use vfs as GitHub codespaces requires vfs
# https://github.com/moby/moby/issues/13742#issuecomment-725197223
RUN mkdir -p /etc/apt/keyrings \
        && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
        && echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null \
        && apt-get update \
        && apt-get install --yes docker-ce docker-ce-cli containerd.io docker-compose-plugin \
        && mkdir -p /etc/docker \
        && echo '{"cgroup-parent":"/actions_job","storage-driver":"vfs"}' >> /etc/docker/daemon.json
