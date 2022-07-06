{ global, pkgs, ... }:
let
  inherit (pkgs) espeak wrapDotenv p2k;
  inherit (global) rootPath;
in {
  services.nixgram = {
    enable = true;
    dotenvFile = rootPath + "/secrets/nixgram.env";
    customCommands = {
      echo = "echo $*";
      uptime = "uptime";
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
      ${p2k}/bin/p2k -a -k $KINDLE_EMAIL -c $AMOUNT -t 30 $EXTRA_PARAMS
      '';
      letsgo = ''
        echo "let's gou"
      '';
    };
  };


}
