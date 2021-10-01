{ pkgs, config, lib, self, ... }:
with (import ../../globalConfig.nix);
{
  imports = [
    "${self.inputs.nixgram}/hmModule.nix"
    "${self.inputs.redial_proxy}/hmModule.nix"
    "${self.inputs.borderless-browser}/home-manager.nix"
    ./modules/dlna.nix
    ./modules/firefox/home.nix
    ./modules/dunst.nix
    ./modules/dummy_module.nix
    ./modules/i3.nix
    # ./modules/webapps.nix
    # ./modules/wallpaper.nix
    ./modules/espanso.nix
    ../../modules/polybar/home.nix
    ../../modules/spotify/home.nix
    ../../modules/tmux/home.nix
    ../../modules/vscode/home.nix
  ]
  ;

  home.packages = with pkgs; [
   # ------------ pacotes do nixpkgs ---------------
    # minecraft  # custom (excluded)
    usb_tixati custom_rofi # custom
    tdesktop # communication
    obsidian
    vlc youtube-dl # media
    chromium
    file
    fortune
    libnotify
    neofetch
    aerc # terminal email
  ] ;

  home.file.".dotfilerc".text = ''
    #!/usr/bin/env bash
    ${self.outputs.environmentShell}
  '';

  programs.hello-world.enable = true;
  services.espanso = {
    enable = true;
    config = 
      let
        justReplace = from: to: {
          trigger = from;
          replace = "${to} ";
        };
        replaceSequence = from: to: {
          trigger = from;
          replace = to;
        };
        replaceWord = from: to: {
          trigger = from;
          replace = to;
          word = true;
          propagate_case = true;
        };
        replaceDate = from: format: {
          trigger = from;
          replace = "{{date}} ";
          vars = [{
            name = "date";
            type = "date";
            params = {
              inherit format;
            };
          }];
        };
        replaceRun = from: command: {
          trigger = from;
          replace = "{{output}} ";
          vars = [{
            name = "output";
            type = "shell";
            params = {
              cmd = pkgs.writeShellScript "espanso-script" command;
            };
          }];
        };
      in {
      matches = [
        # macros
        (justReplace ":email" "lucas59356@gmail.com")
        (justReplace ":me" "Lucas Eduardo Wendt")
        (justReplace ":shrug" "¯\\_(ツ)_/¯")
        (justReplace ":lenny" "( ͡° ͜ʖ ͡°)")
        (replaceDate ":hoje" "%d/%m/%Y")
        (replaceDate ":ot" "#datetime/%Y/%m/%e/%H/%M")
        (replaceDate ":od" "#datetime/%Y/%m/%e")
        (replaceSequence "°" "\\") # Alt+E, Alt+Q outputs /

        # code
        (justReplace ":<html>" ''
          <!DOCTYPE html>
          <html lang="en">
          <head>
          <meta charset="UTF-8">
          <meta http-equiv="X-UA-Compatible" content="IE=edge">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Document</title>
          </head>
          <body>
          $|$
          </body>
          </html>
        '')
        (justReplace ":import React" ''
          import React from 'react';

          interface ComponentProps {
            children: React.ReactNode
          }

          export default function Component(props: ComponentProps) {
            return (
              <>
                $|$
              </>
            )
          }
        '')
        (justReplace ":#include" ''
          #include <stdio.h>
          #include <stdlib.h>
          #include <unistd.h>

          int main(int argc, char **argv) {
            $|$
          }
        '')
        (justReplace ":package" ''
          package main

          import (
            "fmt"
            "github.com/davecgh/go-spew/spew"
          )

          func init() {
          }

          func main() {
            $|$
          }
        '')
        (justReplace ":#!/usr/bin/env bash" ''
          #!/usr/bin/env bash
          set -eu -o pipefail
          # set -f # if glob patterns are undesirable

          function bold {
              echo -e "$(tput bold)$@$(tput sgr0)"
          }
          function red {
              echo -e "\033[0;31m$@\033[0m"
          }
          function error {
            echo -e "$(red error): $*"
            exit 1
          }

          function usage {
            echo "$(bold "$0"): lucasew's default script template
            - $(bold "command"): do something"
          }

          if [ $# == 0 ]; then
            usage
            error "no command specified"
          fi

          COMMAND="$1"; shift

          case "$COMMAND" in
            command)
              echo "Doing something..."
              error "nothing specified"
            ;;
            *)
              error "command $COMMAND not specified"
            ;;
          esac
        '')

        # atalhos
        (replaceRun ":blaunch" "webapp > /dev/null") # borderless browser
        (replaceRun ":globalip" "curl ifconfig.me ")
        (replaceRun ":lero" "lero") # https://github.com/lucasew/lerolero.sh
        (replaceRun ":lockscreen" "loginctl lock-session")

        # typos
        (replaceWord "lenght" "length")
        (replaceWord "ther" "there")
        (replaceWord "automacao" "automação")
        (replaceWord "nixos" "NixOS")
        (replaceWord "its" "it's")
        (replaceWord "dont" "don't")
        (replaceWord "didnt" "didn't")
        (replaceWord "arent" "aren't")
        (replaceWord "youre" "you're")
      ];
    };
  };

  services.redial_proxy.enable = true;

  programs = {
    # adskipped-spotify.enable = true;
    command-not-found.enable = true;
    jq.enable = true;
    obs-studio = {
      enable = true;
    };
    htop = {
      enable = true;
      settings = {
        hideThreads = true;
        treeView = true;
      };
    };
    tmux.enable = true;
    vscode.enable = true;
  };

  # Git
  programs.git = {
        enable = true;
        userName = username;
        userEmail = email;
  };

  # KDE connect
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  # Polybar
  services.polybar.enable = true;
  xsession.windowManager.i3.enable = true;

  # Dconf
  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-options = "zoom";
      primary-color = "#ffffff";
      secondary-color = "#000000";
    };
    "org/gnome/desktop/input-sources" = 
      let
        tuple = lib.hm.gvariant.mkTuple;
      in 
    {
      current = "uint32 0";
      sources = [(tuple ["xkb" "br"]) (tuple ["xkb" "us"])];
      xkb-options = [ "terminate:ctrl_alt_bksp" ];
    };
    "org/gnome/desktop/interface" = {
      cursor-theme = "Adwaita";
      gtk-im-module = "gtk-im-context-simple";
      gtk-theme = "Adwaita-dark";
    };
    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = false;
    };
    "org/gnome/desktop/privacy" = {
      disable-microphone = true;
      report-technical-problems = false;
    };
    "org/gnome/system/location" = {
      enabled = false;
    };
    "org/gnome/desktop/periphereals/touchpad" = {
      tap-to-click = true;
    };
  };

  # nixgram
  services.nixgram = with pkgs; {
    enable = true;
    dotenvFile = rootPath + "/secrets/nixgram.env";
    customCommands = {
      echo = "echo $*";
      wait = ''
        sleep $1
        echo Waited for $1 seconds!
      '';
      speak = ''
        ${espeak}/bin/espeak -v mb/mb-br1 "$*"
      '';
      flow = wrapDotenv "flows.env" ''
      PAYLOAD="
      {
          \"ref\": \"main\"
      }
      "
      curl \
        -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        "https://api.github.com/repos/lucasew/flows/actions/workflows/2929078/dispatches" \
        -d "$PAYLOAD" || echo "Fail" && echo "Ok"
      '';
      p2k = wrapDotenv "p2k.env" ''
      unset QT_QPA_PLATFORMTHEME
      export AMOUNT=10

      if [ -n "$DEFAULT_AMOUNT" ]; then
          AMOUNT=$DEFAULT_AMOUNT
      fi

      if [ -n "$1" ]; then
          AMOUNT=$1
      fi

      if [ -n "$TESTING" ]; then
          exit 0
      fi
      ${p2k}/bin/p2k -k $KINDLE_EMAIL -c $AMOUNT -t 30 $EXTRA_PARAMS
      '';
      letsgo = ''
        echo "let's gou"
      '';
    };
  };
  services.flameshot.enable = true;

#   # wallpaper
#   wallpaper = {
#     enable = true;
#     wallpaperFile = wallpaper;
#   };


  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  gtk = {
    enable = true;
    theme.name = "Adwaita-dark";
  };
  qt = {
    enable = true;
    platformTheme = "gtk";
  };
  # home.stateVersion = "20.03";

  borderless-browser.apps = {
    teste = {
      desktopName = "Teste";
      url = "https://google.com";
    };
    whatsapp = {
      desktopName = "WhatsApp";
      url = "web.whatsapp.com";
      icon = builtins.fetchurl {
        url = "https://raw.githubusercontent.com/jiahaog/nativefier-icons/gh-pages/files/whatsapp.png";
        sha256 = "1f5bwficjkqxjzanw89yj0rz66zz10k7zhrirq349x9qy9yp3bmc";
      };
    };
    notion = {
      desktopName = "Notion";
      url = "notion.so";
      icon = builtins.fetchurl {
        url = "https://logos-download.com/wp-content/uploads/2019/06/Notion_App_Logo.png";
        sha256 = "16vw52kca3pglykn9q184qgzshys3d2knzy631rp2slkbr301zxf";
      };
    };
    duolingo = {
      desktopName = "Duolingo";
      url = "duolingo.com";
      icon = builtins.fetchurl {
        url = "https://logos-download.com/wp-content/uploads/2016/10/Duolingo_logo_owl.png";
        sha256 = "1059lfaij0lmm1jsywfmnin9z8jalqh8yar9r8sj0qzk4nmjniss";
      };
    };
    youtube-music =  {
      desktopName = "Youtube Music";
      url = "music.youtube.com";
      icon = builtins.fetchurl {
        url = "https://vancedapp.com/static/media/logo.866a4e0b.svg";
        sha256 = "1axznpmfgmfqjgnq7z7vdjwmdsrk0qpc1rdlv9yyrcxfkyzqmvdv";
      };
    };
    planttext =  {
      desktopName = "PlantText";
      url = "https://www.planttext.com/";
      icon = builtins.fetchurl {
        url = "https://www.planttext.com/images/blue_gray.png";
        sha256 = "0n1p8g7gjxdp06fh36yqb10jvcbhxfc129xpvi1b10k1qb1vlj1h";
      };
    };
    rainmode =  {
      desktopName = "Tocar som de chuva";
      url = "https://youtu.be/mPZkdNFkNps";
      icon = "weather-showers";
    };
    gmail =  {
      desktopName = "GMail";
      url = "gmail.com";
      icon = builtins.fetchurl {
        url = "https://icons.iconarchive.com/icons/dtafalonso/android-lollipop/256/Gmail-icon.png";
        sha256 = "1cldc9k30rlvchh7ng00hmn0prbh632z8h9fqclj466y8bgdp15j";
      };
    };
    keymash =  {
      desktopName = "keyma.sh: Keyboard typing train";
      url = "https://keyma.sh/learn";
      icon = builtins.fetchurl {
        url = "https://keyma.sh/static/media/logo_svg.ead5cacb.svg";
        sha256 = "1i6py2gnpmf548zwakh9gscnk5ggsd1j98z80yb6mr0fm84bgizy";
      };
    };
    calendar =  {
      desktopName = "Calendário";
      url = "https://calendar.google.com/calendar/u/0/r/customday";
      icon = "x-office-calendar";
    };
    twitchLive =  {
      desktopName = "Dashboard de Live";
      url = "https://dashboard.twitch.tv/stream-manager";
    };
    trello-facul = {
      desktopName = "Trello Faculdade";
      url = "https://trello.com/b/ov0pbUtC/facul";
    };
    trello-pessoal = {
      desktopName = "Trello Pessoal";
      url = "https://trello.com/b/bjoRKSM2/pessoal";
    };
    trello-sides = {
      desktopName = "Trello Side Projects";
      url = "https://trello.com/b/36ncJYYV/side-projects";
    };
  };

}
