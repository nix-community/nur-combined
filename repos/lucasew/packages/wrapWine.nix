with builtins;
{ pkgs }:
{ 
  is64bits ? false
  , wine ? if is64bits then pkgs.wineWowPackages.stable else pkgs.wine
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
  wineBin = "${wine}/bin/wine${if is64bits then "64" else ""}";
  script = pkgs.writeShellScriptBin name ''
    export WINEARCH=${if is64bits then "win64" else "win32"}
    PATH=$PATH:${wine}/bin:${pkgs.winetricks}/bin
    HOME="$(echo ~)"
    WINE_NIX="$HOME/.wine-nix"
    export WINEPREFIX="$WINE_NIX/${name}"
    EXECUTABLE="${executable}"
    mkdir -p "$WINE_NIX"
    ${setupScript}
    if [ ! -d "$WINEPREFIX" ]
    then
      ${wine}/bin/wineboot
      # ${wineBin} cmd /c dir > /dev/null 2> /dev/null # initialize prefix
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

    ${wineBin} ${wineFlags} "$EXECUTABLE" "$@"
    wineserver -w
  '';
in
script
