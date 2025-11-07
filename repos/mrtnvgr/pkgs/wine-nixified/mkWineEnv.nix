{ stdenv, lib, writeShellApplication, cabextract, winetricks, wine-staging }:
let
  inherit (builtins) length concatStringsSep;
  inherit (lib) optionalString;
in
{ name
, is64bits ? stdenv.hostPlatform.system == "x86_64-linux"

, tricks ? [ ]
, silent ? true

, setupScript ? ""

, wine ? wine-staging

, fsync ? false
, esync ? false

, ...
}:
let
  tricksHook = optionalString ((length tricks) > 0) /* bash */ ''
    pushd $(mktemp -d)
      ${winetricks}/bin/winetricks ${optionalString silent "-q"} ${concatStringsSep " " tricks}
    popd
  '';

  boolToInt = x: if x then "1" else "0";
in writeShellApplication {
  inherit name;

  runtimeInputs = [ wine cabextract ];

  text = /* bash */ ''
    WINEARCH=win${if is64bits then "64" else "32"}

    WINEFSYNC=${boolToInt fsync}
    WINEESYNC=${boolToInt esync}

    WINE_NIX="$HOME/.wine-nix"
    WINEPREFIX="$WINE_NIX/${name}"
    mkdir -p "$WINE_NIX"

    if [ ! -d "$WINEPREFIX" ]; then
      wineboot --init
      wineserver -w

      ${tricksHook}
      wineserver -w

      ${setupScript}
    fi
  '';
}
