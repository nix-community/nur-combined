# Thanks to @lucasew <3
# https://github.com/lucasew/nixcfg/blob/047c4913e9dceedd4957fb097bbf4803e5278563/nix/pkgs/wrapWine.nix

{ pkgs }:
let
  inherit (builtins) length concatStringsSep;
  inherit (pkgs) lib cabextract winetricks writeShellScriptBin;
  inherit (lib) makeBinPath;
in
{ name
, executable
, is64bits ? false
, tricks ? [ ]
, silent ? true
, chdir ? null
, preScript ? ""
, postScript ? ""
, setupScript ? ""
, wine ? if is64bits then pkgs.wineWowPackages.stagingFull else pkgs.wine-staging
, wineFlags ? ""
# Useful for native linux apps that require wine environment (e.g. reaper with yabridge)
, isWinBin ? true,
}:
let
  wineBin = "${wine}/bin/wine${if is64bits then "64" else ""}";

  requiredPackages = [ wine cabextract ];

  tricksHook =
    if (length tricks) > 0 then
      let
        tricksStr = concatStringsSep " " tricks;
        tricksCmd = ''
          pushd $(mktemp -d)
            ${winetricks}/bin/winetricks ${if silent then "-q" else ""} ${tricksStr}
          popd
        '';
      in
      tricksCmd
    else "";

  script = writeShellScriptBin name ''
    export WINEARCH=win${if is64bits then "64" else "32"}
    export PATH=${makeBinPath requiredPackages}:$PATH

    export WINE_NIX="$HOME/.wine-nix"
    export WINEPREFIX="$WINE_NIX/${name}"
    mkdir -p "$WINE_NIX"

    if [ ! -d "$WINEPREFIX" ]; then
      wineboot --init
      wineserver -w

      ${tricksHook}
      wineserver -w

      ${setupScript}
    fi

    ${if chdir != null
      then ''cd "${chdir}"''
      else ""}

    # $REPL is defined => start a shell in the context
    if [ ! "$REPL" == "" ]; then
      bash; exit 0
    fi

    ${preScript}

    ${if isWinBin then ''${wineBin} ${wineFlags}'' else ""} "${executable}" "$@"

    wineserver -w

    ${postScript}
  '';
in
script
