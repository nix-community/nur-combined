{ lib, mkBashCli, callPackage }:

let
  spinners = callPackage ./spinners.nix {};

in mkBashCli "kretty" "placeholder for random tty scriptlets" {} (mkCmd:
    [
      (mkCmd "colortest" "Show available tty colours" { aliases = [ "colors" ]; } ''
        awk 'BEGIN{
          s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
          for (colnum = 0; colnum<77; colnum++) {
            r = 255-(colnum*255/76); g = (colnum*510/76);
            b = (colnum*255/76);
            if (g>255) g = 510-g;
            printf "\033[48;2;%d;%d;%dm", r,g,b;
            printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
            printf "%s\033[0m", substr(s,colnum+1,1);
          }
          printf "\n";
        }'
      '')

      (mkCmd "color" "Print strings in color" {}
        (let
          colors = {
            black   = "30";
            red     = "31";
            green   = "32";
            yellow  = "33";
            blue    = "34";
            magenta = "35";
            cyan    = "36";
            white   = "37";
          };
        in lib.mapAttrsToList (colorName: colorCode: mkCmd colorName "print string in ${colorName}" {
          arguments = a: [ (a "strings" "string or strings to print") ];
        } ''
          echo -en "\e[${colorCode}m"
          if [[ -t 0 ]]; then
            echo -e $STRINGS "$@"
          else
            cat
          fi
          echo -en "\e[0m"
        ''
        ) colors)
      )

      (mkCmd "spinners" "List available spinners" {} ''
        ls ${spinners}
      '')

      (mkCmd "spinner" "Play a spinner until interrupted" {
        aliases = [ "spin" ];
        arguments = a: [ (a "spinner" "name of the spinner to be played") ];
      } ''
        # This gets rid of the cursor (takes away from the spinner)
        tput civis

        # This brings the cursor back
        trap 'tput cnorm' EXIT


        if ! [[ -f ${spinners}/$SPINNER ]]; then
          >&2 echo "I don't know how to spin $SPINNER sry"
          exit 1
        fi

        source ${spinners}/$SPINNER

        # This is so that we get the right length of emojis
        LANG=C LC_ALL=C

        while true; do
          for frame in "''${frames[@]}"; do
            printf "$frame"
            sleep $interval
            for ((i = 0; i < ''${#frame}; i++)); do
              printf '\b'
            done
          done
        done
      '')
    ]
  )
