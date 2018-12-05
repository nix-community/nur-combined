{ config ? {}, lib, pkgs, ... }:

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
  kubectx = pkgs.nur.repos.moredhel.kubectx;
  kubectl = unstable.kubectl;
in
{
  # home.packages = hm.base ++ hm.ui;

  home.keyboard = {
    layout = "dvorak";
  };

  services.syncthing.enable = true;

  programs.bash = {
    enable = true;
    historyControl = [
      "erasedups"
      "ignoredups"
      "ignorespace"
    ];
    shellAliases = {
      g = "git";
      vim = "emacsclient --socket /tmp/emacs1000/server -nw";
      emacs = "emacsclient --socket /tmp/emacs1000/server -c -n";
      k = "${kubectl}/bin/kubectl";
      ktx = "${kubectx}/bin/kubectx";
      kns = "${kubectx}/bin/kubens";
    };
    enableAutojump = true;
  };

  programs.git = {
    enable = true;
    userName = "Hamish Hutchings";
    userEmail = "moredhel@aoeu.me";
    signing = {
      signByDefault = true;
      key = "A1390B0803E1F325433A18EF80784F5CAD59A3F4";
    };
    aliases = {
      co = "checkout";
      s = "status";
      d = "diff --color";
      a = "add";
      cm = "commit";
      l = "log --color";
      b = "branch";
      f = "flow";
    };
    extraConfig = ''
      [color]
      ui = true

      [merge]
      conflictstyle = diff3
      tool = vimdiff
      
      [push]
      default = simple
      
      [url "ssh://git@github.com/"]
      insteadOf = https://github.com/
    '';
  };

  # fix for failing manpage build
  manual.manpages.enable = false;
  programs.home-manager = {
    enable = true;
    path = https://github.com/rycee/home-manager/archive/master.tar.gz;
  };
}
