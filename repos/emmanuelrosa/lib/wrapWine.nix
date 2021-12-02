# Based on code from: https://raw.githubusercontent.com/lucasew/nixcfg/fd523e15ccd7ec2fd86a3c9bc4611b78f4e51608/packages/wrapWine.nix
with builtins;
{ pkgs }:
{ wine
, wineArch ? "win32"
, wineFlags ? ""
, executable
, chdir ? null
, name
, tricks ? [ ]
, setupScript ? ""
, firstrunScript ? ""
}:
let
  tricksStmt =
    if (length tricks) > 0 then
      concatStringsSep " " tricks
    else
      "-V";
  script = pkgs.writeShellScriptBin name ''
    PATH=$PATH:${wine}/bin:${pkgs.winetricks}/bin
    HOME="$(echo ~)"
    WINE_NIX="$HOME/.wine-nix"
    export WINEPREFIX="$WINE_NIX/${name}"
    export WINEARCH="${wineArch}"
    EXECUTABLE="${executable}"
    mkdir -p "$WINE_NIX"
    ${setupScript}
    if [ ! -d "$WINEPREFIX" ]
    then
      # wine cmd /c dir > /dev/null 2> /dev/null # initialize prefix
      wine boot --init
      wineserver -w
      winetricks ${tricksStmt}
      ${firstrunScript}
    fi
    ${if chdir != null then ''cd "${chdir}"'' else ""}
    if [ ! "$REPL" == "" ];
    then
      bash
      exit 0
    fi

    wine ${wineFlags} "$EXECUTABLE" "$@"
    wineserver -w
  '';
in
script
