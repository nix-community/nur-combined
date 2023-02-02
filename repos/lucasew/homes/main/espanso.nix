{ pkgs, ... }:
let
  inherit (pkgs) writeShellScript;
in {
  services.espanso = {
    enable = true;
    settings =
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
              cmd = writeShellScript "espanso-script" command;
            };
          }];
        };
      in {
      matches = [
        # macros
        (justReplace ":email:" "lucas59356@gmail.com")
        (justReplace ":shrug:" "¯\\_(ツ)_/¯")
        (justReplace ":lenny:" "( ͡° ͜ʖ ͡°)")
        (justReplace ":fino:" "🗿🍷")
        (replaceDate ":hoje:" "%d/%m/%Y")
        (replaceSequence "°" "\\") # Alt+E, Alt+Q outputs /
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
        (replaceRun ":blaunch:" "/run/current-system/sw/bin/webapp > /dev/null") # borderless browser
        (replaceRun ":globalip:" "/run/current-system/sw/bin/curl ifconfig.me ")
        (replaceRun ":lero:" "/run/current-system/sw/bin/lero") # https://github.com/lucasew/lerolero.sh
        (replaceRun ":lockscreen:" "/run/current-system/sw/bin/loginctl lock-session 2>&1")
        (replaceRun ":nixinfo:" "/run/current-system/sw/bin/nix-shell -p nix-info --run 'nix-info -m'")

        # typos
        (replaceWord "lenght" "length")
        (replaceWord "ther" "there")
        (replaceWord "automacao" "automação")
        (replaceWord "its" "it's")
        (replaceWord "dont" "don't")
        (replaceWord "didnt" "didn't")
        (replaceWord "cant" "can't")
        (replaceWord "shouldnt" "shouldn't")
        (replaceWord "arent" "aren't")
        (replaceWord "youre" "you're")
      ];
    };
  };
}
