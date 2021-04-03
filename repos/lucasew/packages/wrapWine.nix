with builtins;
{ pkgs }:
{ wine ? pkgs.wine
, wineFlags ? ""
, executable
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
    PATH=$PATH:${wine}/bin
    HOME="$(echo ~)"
    WINE_NIX="$HOME/.wine-nix"
    export WINEPREFIX="$WINE_NIX/${name}"
    mkdir -p "$WINE_NIX"
    ${setupScript}
    if [ ! -d "$WINEPREFIX" ]
    then
      wine cmd /c dir > /dev/null 2> /dev/null # initialize prefix
      wineserver -w
      ${pkgs.winetricks}/bin/winetricks ${tricksStmt}
      ${firstrunScript}
    fi
    ${wine}/bin/wine ${wineFlags} "${executable}" "$@"
  '';
in
script
