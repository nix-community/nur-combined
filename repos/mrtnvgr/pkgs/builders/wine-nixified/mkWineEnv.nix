{ stdenv, lib, writeShellApplication, writeText, cabextract, winetricks, wine-staging }:
{ name
, is64bits ? stdenv.hostPlatform.system == "x86_64-linux"

, tricks ? [ ]
, silent ? true

, initScript ? ""

, postScript ? ""

, wine ? wine-staging

, fsync ? false
, esync ? false

, allowSubstitutes ? false

, ...
}:
let
  boolToInt = x: if x then "1" else "0";

  envVars = /* bash */ ''
    export WINEARCH=win${if is64bits then "64" else "32"}

    export WINEFSYNC=${boolToInt fsync}
    export WINEESYNC=${boolToInt esync}

    export WINE_NIX="$HOME/.wine-nix"
    export WINEPREFIX="$WINE_NIX/${name}"

    case ":$PATH:" in
      *":${winetricks}/bin:"*) ;;
      *) export PATH="${wine}/bin:${winetricks}/bin:$PATH" ;;
    esac
  '';

  tricksHook = lib.optionalString ((builtins.length tricks) > 0) /* bash */ ''
    pushd "$(mktemp -d)"
      ${winetricks}/bin/winetricks ${lib.optionalString silent "-q"} ${builtins.concatStringsSep " " tricks}
    popd
  '';

  activateScript = writeText "activate-${name}" /* bash */ ''
    # Source this file to enter the "${name}" wine environment:
    #   source "$HOME/.wine-nix/${name}/activate"
    # Leave it with: deactivate

    _OLD_WINEPREFIX="''${WINEPREFIX-}"
    _OLD_PATH="$PATH"

    ${envVars}

    deactivate() {
      if [ -n "''${_OLD_WINEPREFIX-}" ]; then
        export WINEPREFIX="$_OLD_WINEPREFIX"
      else
        unset WINEPREFIX
      fi
      unset WINEARCH WINEFSYNC WINEESYNC WINE_NIX
      export PATH="$_OLD_PATH"
      unset _OLD_WINEPREFIX _OLD_PATH
      unset -f deactivate
    }
  '';
in (writeShellApplication {
  inherit name;

  runtimeInputs = [ wine cabextract ];

  text = /* bash */ ''
    ${envVars}

    mkdir -p "$WINE_NIX"

    if [ ! -d "$WINEPREFIX" ]; then
      wineboot --init
      wineserver -w

      ${tricksHook}
      wineserver -w

      ${initScript}
    fi

    ${postScript}

    ln -sf ${activateScript} "$WINEPREFIX/activate"
  '';
}).overrideAttrs {
  # TODO: https://github.com/NixOS/nixpkgs/issues/344414
  inherit allowSubstitutes;
}
