{ lib, grid, stdenv, bashInteractive, shfmt, writeText, runCommand }:

name: description: { packages ? [], arguments ? [], aliases ? [], options ? [], flags ? [], preInit ? "", init ? "" }: action: let
  defaultFlags = [ (mkFlag "h" "help" "show help") ];

  mkArgument = name:                 description: { inherit name               description; };
  mkFlag     = short: long:          description: { inherit short long         description; };
  mkOption   = short: long: default: description: { inherit short long default description; };

  mkGetOpts = { usage, options ? [], flags ? [], ... }: ''
    # Setup defaults
    ${lib.concatMapStrings ({ long, ... }: ''
      ${lib.toUpper long}=false
      ${long}=false
    '') (defaultFlags ++ flags)}

    ${lib.concatMapStrings ({ long, default ? null, ...}: ''
      ${lib.optionalString (default != null) ''
        ${lib.toUpper long}="${default}"
        ${long}="${default}"
      ''}
    '') options}

    while [[ $# > 0 ]]; do
      key="$1"

      case $key in
        ${lib.concatMapStrings ({ short, long, ... }:
        ''-${short} | --${long} )
          ${lib.toUpper long}=true
          ${long}=true
          shift
          ;;
          '') (defaultFlags ++ flags)}
        ${lib.concatMapStrings ({ short, long, ... }:
        ''-${short} | --${long} )
          ${lib.toUpper long}="$2"
          ${long}="$2"
          shift 2
          ;;
          '') options}
        *) break ;;
      esac
    done

    # Assert all options are defined
    ${lib.concatMapStrings ({ long, ...}: ''
      if ! [[ -v ${lib.toUpper long} ]] && ! $HELP; then
        err "required option '${long}' has not been set"
        opts_failed=
      fi
    '') options}

    if [[ -v opts_failed ]] || $HELP; then
      . ${usage}
      exit 1
    fi
  '';

  mkUsageText = { name, description, arguments ? [], flags ? [], options ? [], commands ? [], previous ? [], ... }: let
    hasCommands = commands != [] && ! builtins.isString commands;
    usageText = ''
      Usage: ${lib.concatStringsSep " " (previous ++ [ name ])} [options/flags] ${lib.optionalString hasCommands "<command> "}${lib.concatMapStringsSep " " ({ name, ... }: "<${name}>") arguments}

        ${description}

    '' + (lib.optionalString (arguments != []) ''
      Arguments:
      ${grid.gridToStringLeft (map ({ name, description, ... }: [
        "    "       # indentation
        name         # argument name
        " |"         # separator
        description  # description
      ]) arguments)}
    '') + (lib.optionalString ((defaultFlags ++ flags) != []) ''
      Flags:
      ${grid.gridToStringLeft (map ({ short, long, description, ... }: [
        "    "       # indentation
        "--${long}"  # long form
        "-${short}"  # short form
        " |"         # separator
        description  # description
      ]) (defaultFlags ++ flags))}
    '') + (lib.optionalString (options != []) ''
      Options:
      ${grid.gridToStringLeft (map ({ short, long, default, description, ... }: [
        "    "       # indentation
        "--${long}"  # long form
        "-${short}"  # short form
        " |"         # separator
        description  # description
        "   [ ${if default != null then "default: ${default}" else "required"} ]"
      ]) options)}
    '') + (lib.optionalString hasCommands ''
      Commands:
      ${grid.gridToStringLeft (map ({ name, description, aliases ? [], ... }: [
        "    "                                            # indentation
        (lib.concatStringsSep ", " ([ name ] ++ aliases)) # command name and aliases
        " |"                                              # separator
        description                                       # description
      ]) commands)}
    '');
  in ''
    cat <<EOF
    ${usageText}
    EOF
  '';

  mkUsage = { name, ... }@c: writeText "${name}-usage.txt" (mkUsageText c);

  mkCli =
    { action
    , name
    , description
    , preInit   ? ""
    , init      ? ""
    , arguments ? []
    , flags     ? []
    , options   ? []
    , previous  ? []
    , packages  ? []
    , ... }@c:

    assert ! builtins.isString action -> arguments == [];
  let
    mkCommand = name: description: { preInit ? "", init ? "", arguments ? [], aliases ? [], options ? [], flags ? [], packages ? [] }: action: {
      inherit action preInit init arguments aliases description flags name options packages;
    };

    commands   = if builtins.isFunction    action then    action mkCommand  else    action;
    arguments' = if builtins.isFunction arguments then arguments mkArgument else arguments;
    flags'     = if builtins.isFunction     flags then     flags mkFlag     else     flags;
    options'   = if builtins.isFunction   options then   options mkOption   else   options;

    usage = mkUsage (c // {
      inherit commands previous;

      arguments = arguments';
      options   = options';
      flags     = flags';
    });

    currentName = name;

  in ''
    PATH=${lib.makeBinPath packages}:$PATH

    ${preInit}

    ${mkGetOpts (c // {
      inherit usage;

      options = options';
      flags   = flags';
    })}

    ${init}

    ${if builtins.isString commands then ''
      ${lib.concatMapStrings ({ name, ...}: ''
        if [[ $# > 0 ]]; then
          ${lib.toUpper name}=$1
          ${name}=$1
          shift
        else
          err "argument '${name}' has not been specified"
          args_failed=
        fi
      '') arguments'}

      if [[ -v args_failed ]] || $HELP; then
        . ${usage}
        exit 1
      fi

      ${commands}

    '' else ''

    if [[ $# > 0 ]]; then
      cmd=$1
      shift
    else
      . ${usage}
      exit 1
    fi

    case $cmd in
      ${lib.concatMapStrings ({ name, aliases ? [], ... }@c: ''
        ${name}${lib.optionalString (aliases != []) "|${lib.concatStringsSep "|" aliases}"})
          ${mkCli (c // { previous = previous ++ [ currentName ]; })}
          ;;
        '') commands}
      *)
        if [[ -n $cmd ]]; then
          err "unknown command: $cmd"
        fi

        . ${usage}
        ;;
    esac
    ''}
  '';

in stdenv.mkDerivation ({
  inherit name;

  phases      = [ "buildPhase" "checkPhase" ];
  buildInputs = [ shfmt ];

  buildPhase = ''
    mkdir -p $out/bin

    cd $_

    cat <<'EOF' | shfmt -i 2 > ${name}
    #!${bashInteractive}/bin/bash

    set -euo pipefail

    stderr() {
      1>&2 echo -e "$@"
    }

    err() {
      stderr "\e[31merror\e[0m:" "$@"
    }

    warn() {
      stderr "\e[33mwarning\e[0m:" "$@"
    }

    cleanup() {
      chmod -R +w $TMP
      rm -rf $_
    }

    TMP=$(mktemp -d --tmpdir ${name}.XXXXXX)
    trap cleanup EXIT

    ${mkCli { inherit arguments action name description options flags preInit init packages; } }

    EOF

    chmod +x ${name}
    ${lib.concatMapStrings (alias: ''
      ln -s ${name} ${alias}
    '') aliases}
  '';

  checkPhase = ''
    true
  '';

  meta.platforms = stdenv.lib.platforms.all;
})
