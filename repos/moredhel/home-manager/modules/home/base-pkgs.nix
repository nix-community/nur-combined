{ pkgs }:
let
  # TODO: clean these up
  unstable = import <nixos-unstable> {};
in
with pkgs;
[
unstable.kubernetes-helm
unstable.minikube
unstable.gitAndTools.hub
unstable.kubectl


cabal-install
mosh
awscli
acpi
docker_compose
nix-prefetch-git
autojump
direnv

packer
terraform
keybase

hledger
telnet
zip
htop
gopass
]
