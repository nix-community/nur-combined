{ pkgs, ... }:
# Retry every 1s if the cannot allocate memory happens
# This is a automation, I keep doing this by hand until now
pkgs.writeShellScriptBin "nixwrap" ''
  TEMPFILE=$(mktemp)
  while [ true ]
  do
      echo "running '$@'"
      "$@" 2> /dev/stdout | tee "$TEMPFILE"
      OUTPUT="$(cat "$TEMPFILE" | grep "Cannot allocate memory")"
      if [ "$OUTPUT" == "" ]
      then
          break
      fi
      echo "aquela questão de ram, tentando de novo"
      sleep 1
  done
''
