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
unstable.dropbox
unstable.firefox-devedition-bin
unstable.powerline-go

xmonad
chromium # user
paprefs
gnome3.gnome_terminal
inkscape
lispPackages.quicklisp
tmuxinator
gimp
reflex
neovim
vscode
pandoc
pypi2nix
skypeforlinux
spotify
enpass
wireshark-gtk
xorg.xmodmap
enlightenment.terminology
pavucontrol

rlwrap
electrum

slack
gnupg
]
