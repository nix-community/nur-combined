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
  home.packages = import ./package-list.nix;

  home.keyboard = {
    layout = "dvorak";
  };

  services.unison = {
    enable = true;
    profiles = {
      org = {
        src = "/home/moredhel/qcal5-ly4wi";
        dest = "/home/moredhel/keybase/private/moredhel/org";
        extraArgs = "-batch -watch -ui text -repeat 60 -fat";
      };
    };
  };

  services.flameshot = {
    enable = true;
  };

  services.unclutter = {
    enable = true;
  };

  services.parcellite = {
    enable = true;
  };

  services.screen-locker = {
    enable = true;
    lockCmd = "${pkgs.i3lock}/bin/i3lock -n -c 000000";
    inactiveInterval = 5;
  };
  services.udiskie = {
    enable = false;
    automount = true;
    notify = true;
  };

  services.network-manager-applet = {
    enable = true;
  };

  services.gpg-agent = {
    enable = false;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  xsession = {
    enable = false;
    windowManager.command = "${xmonad}/bin/xmonad";
    initExtra = ''
        # import user environment variables (HACK)
        systemctl  --user import-environment

        # TODO create a damn module for this!
        # same with this
        ${pkgs.xcape}/bin/xcape
    '';
  };

  programs.rofi = {
    enable = true;
  };

  programs.browserpass = {
    enable = true;
    browsers = ["firefox" "chromium"];
  };

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
      cat = "${pkgs.bat}/bin/bat";
    };
    enableAutojump = true;

    initExtra = ''
      # Custom Editor
      EDITOR="emacsclient --socket /tmp/emacs1000/server -nw"
      # extend PATH
      PATH=$PATH:$HOME/node_modules/.bin
      complete -F _git g # allow completion for git alias
      # complete -F _kubectl k # allow completion for git alias
      
      # print out unsupported packages
      PKGS=$(grep "edge\\." $HOME/.config/nixpkgs/home.nix | awk '{$1=$1};1' | cut -d'.' -f2)
      if [ -z "$PKGS" ]; then
	      true
      else
        echo "--- Unsupported Packages ---"
        echo "$PKGS"
        echo "----------------------------"
      fi

      # uncomment this to enable the direnv hook.
      # eval "$(${pkgs.direnv}/bin/direnv hook bash)"

      # custom helm stuff
      # TODO: fix me/split me out into a helper script...
      h() {
          declare clone=$1
          : {clone=? required}

          if [[ $\{clone\} == "" ]]; then
              echo "a repo must be provided"
              exit 1
          fi

          cd /data/src/hub/
          mkdir -p $clone
          hub clone $clone $clone
          cd $clone
          echo "start contributing..."
      }
      
      function _update_ps1() {
          PS1="$(${unstable.powerline-go}/bin/powerline-go -error $?)"
      }

      PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
    '';
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

  gtk = {
    enable = true;
    theme = {
      package = pkgs.breeze-qt5;
      name = "Breeze-gtk";
    };
    iconTheme = {
      package = pkgs.breeze-qt5;
      name = "breeze";
    };
  };
}
