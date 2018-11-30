{ lib, stdenv, bash, writeText }:

name: description: env: commandsFn: let
  mkCommand = command: description: code: {
    inherit command description code;
  };

  commands = commandsFn mkCommand;

  maxCommandLength = with lib; let
    commandLengths = map ({ command, ... }: stringLength command) commands;
    maxLength = builtins.foldl' max 0 commandLengths;
  in maxLength;

  usage = writeText "${name}-usage.txt" ''
    Usage: ${name} [--version] [--help] <command> [args]

    Description:
    ${description}

    The available commands for execution are listed below.

    Commands:
    ${lib.concatMapStrings ({ command, description, ... }: with lib; let
      indentSize    = 4;
      commandLength = stringLength command;
      indentation   = fixedWidthString indentSize " " "";
      spacer        = fixedWidthString (maxCommandLength + indentSize - commandLength) " " "| ";
    in ''
      ${indentation}${command}${spacer}${description}
    '') commands}
  '';

in stdenv.mkDerivation ({
  inherit name;
  phases = [ "buildPhase" "checkPhase" ];

  buildPhase = ''
    binary=$out/bin/${name}
    mkdir -p $(dirname $binary)

    cat <<'EOF' > $binary
    #!${bash}/bin/bash

    set -eo pipefail

    stderr() {
      1>&2 echo -e "$@"
    }

    err() {
      stderr "\e[31merror\e[0m:" "$@"
    }

    cmd=$1

    if [[ -n $cmd ]]; then shift; fi

    case $cmd in
      ${lib.concatMapStrings ({ command, code, ... }: ''
        ${command})
          ${code}
          ;;
      '') commands}
      *)
        cat ${usage}
        ;;
      esac
    EOF

    chmod +x $binary
    '';
} // env)
