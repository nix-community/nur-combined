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
with pkgs;
[
unstable.discord
unstable.google-chrome
unstable.kubernetes-helm
unstable.minikube
unstable.dropbox
unstable.firefox-devedition-bin
unstable.gitAndTools.hub

xmonad
kubectl

chromium # user

cabal-install
google-drive-ocamlfuse
mosh
paprefs
awscli
acpi
docker_compose
gnome3.gnome_terminal
inkscape
lispPackages.quicklisp
nix-prefetch-git
autojump
direnv
ble.powerline-go
gimp
reflex

packer
terraform

neovim
vscode

keybase

pandoc

hledger
pypi2nix
skypeforlinux
spotify
enpass
telnet
wireshark-gtk
xorg.xmodmap
zip
htop
fortune
enlightenment.terminology
pavucontrol

rlwrap
electrum

slack
gnupg
gopass
franz
]
