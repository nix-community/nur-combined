{ lib, grid, stdenv, bash, writeText }:

name: description: env: commandsFn: let
  mkCommand = command: description: code: {
    inherit command description code;
  };

  commands = commandsFn mkCommand;

  usage = writeText "${name}-usage.txt" ''
    Usage: ${name} [--version] [--help] <command> [args]

    Description:
    ${description}

    The available commands for execution are listed below.

    Commands:
    ${grid.gridToStringLeft (map ({ command, description, ... }: [ "    " command " |" description ]) commands)}
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
