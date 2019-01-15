{ mkBashCli, callPackage }:

let
  spinners = callPackage ./spinners.nix {};
in
mkBashCli "kretty" "placeholder for random tty scriptlets" {} (mkCmd:
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

      (mkCmd "spinners" "List available spinners" {} ''
        ls ${spinners}
      '')

      (mkCmd "spinner" "Play a spinner until interrupted" { aliases = [ "spin" ]; } ''
        trap 'tput cnorm' EXIT
        tput civis

        if ! [[ -f ${spinners}/$1 ]]; then
          >&2 echo "I don't know how to spin $1 sry"
          exit 1
        fi

        source ${spinners}/$1

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
