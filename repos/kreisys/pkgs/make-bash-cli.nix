{ lib, grid, stdenv, bash, writeText }:

name: description: { env ? {}, options ? [], flags ? [] }: commandsFn: let

  mkCommand = command: description: { aliases ? [], options ? [], flags ? [] }: code: {
    inherit command description aliases code options flags;
  };

  commands = commandsFn mkCommand;

  mkGetOpts = { options ? [], flags ? [] }: let
    mkOption = short: long: default: { inherit short long default; };
    options' = if builtins.isFunction options then options mkOption else options;

    mkFlag = short: long: { inherit short long; };
    flags' = if builtins.isFunction flags then flags mkFlag else flags;
  in ''
    POSITIONAL=()

    # Setup defaults
    ${lib.concatMapStrings ({ long, ...}: ''
      ${lib.toUpper long}=false
    '') flags'}

    ${lib.concatMapStrings ({ long, default ? null, ...}: ''
      ${lib.optionalString (default != null) ''
        ${lib.toUpper long}="${default}"
      ''}
    '') options'}

    while [[ $# -gt 0 ]]
    do
    key="$1"

    case $key in
      ${lib.concatMapStrings ({ short, long, ...}:
      ''-${short} | --${long} )
        ${lib.toUpper long}=true
        shift
        ;;
        '') flags'}
      ${lib.concatMapStrings ({ short, long, ...}:
      ''-${short} | --${long} )
        ${lib.toUpper long}="$2"
        shift 2
        ;;
        '') options'}

      *)    # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
    done
    set -- "''${POSITIONAL[@]}" # restore positional parameters
  '';

  usage = writeText "${name}-usage.txt" ''
    Usage: ${name} [--version] [--help] <command> [args]

    Description:
    ${description}

    The available commands for execution are listed below.

    Commands:
    ${grid.gridToStringLeft (map ({ command, description, aliases, ... }: [
      "    "                                               # indentation
      (lib.concatStringsSep ", " ([ command ] ++ aliases)) # command name and aliases
      " |"                                                 # separator
      description                                          # command description
    ]) commands)}
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

    ${mkGetOpts { inherit options flags; }}

    cmd=$1

    if [[ -n $cmd ]]; then shift; fi

    case $cmd in
      ${lib.concatMapStrings ({ command, code, aliases, options, flags, ... }: ''
        ${command}${lib.optionalString (aliases != []) "|${lib.concatStringsSep "|" aliases}"})
          ${mkGetOpts { inherit options flags; }}
          ${code}
          ;;
        '') commands}
      *)
        if [[ -n $cmd ]]; then
          err "unknown command: $cmd"
        fi

        cat ${usage}
        ;;
      esac
    EOF

    chmod +x $binary
    '';
} // env)
