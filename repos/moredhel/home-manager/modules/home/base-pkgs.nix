{ pkgs }:
let
  # TODO: clean these up
  # unstable = import <nixos-unstable> {};
  unstable = pkgs;
in
with pkgs;
[
# unstable.kubernetes-helm # don't really want this
# unstable.minikube
# unstable.kubectl # included as an alias
# packer # tooling specific
# terraform # tooling specific
# cabal-install # language specific
# acpi # linux specific

tmux
silver-searcher
unstable.gitAndTools.hub
mosh
awscli
google-cloud-sdk
docker_compose
nix-prefetch-git
autojump
direnv

keybase

hledger
telnet
zip
htop
gopass
]
