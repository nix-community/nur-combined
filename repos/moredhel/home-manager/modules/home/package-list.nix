{ pkgs }:
let
  xmonad = pkgs.xmonad-with-packages.override {
  packages = self: [
    self.xmonad-contrib
    self.xmonad-extras
    ];
  };

  # TODO: clean these up
  unstable = import <nixos-unstable> {};
  edge = import /data/src/nix/nixpkgs {};

  kubectl = unstable.kubectl;
in
[
unstable.discord
unstable.google-chrome
unstable.kubernetes-helm
kubectl
unstable.minikube
unstable.dropbox
unstable.firefox-devedition-bin
unstable.gitAndTools.hub

pkgs.cabal-install
pkgs.google-drive-ocamlfuse
pkgs.mosh
pkgs.paprefs
pkgs.awscli
pkgs.acpi
pkgs.docker_compose
pkgs.gnome3.gnome_terminal
pkgs.inkscape
pkgs.lispPackages.quicklisp
pkgs.nix-prefetch-git
pkgs.autojump
pkgs.direnv
unstable.powerline-go
pkgs.gimp
pkgs.tmuxinator
pkgs.reflex

pkgs.packer
pkgs.terraform

pkgs.neovim
pkgs.vscode

pkgs.keybase

pkgs.pandoc

pkgs.hledger
pkgs.pypi2nix
pkgs.skypeforlinux
pkgs.spotify
pkgs.enpass
pkgs.telnet
pkgs.wireshark-gtk
pkgs.xorg.xmodmap
pkgs.zip
pkgs.htop
pkgs.fortune
pkgs.enlightenment.terminology
pkgs.pavucontrol

pkgs.rlwrap
pkgs.electrum

pkgs.slack
pkgs.gnupg
pkgs.gopass
pkgs.franz

xmonad
]
