with builtins;
{ pkgs }:
{ wine ? pkgs.wine
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
    EXECUTABLE="${executable}"
    mkdir -p "$WINE_NIX"
    ${setupScript}
    if [ ! -d "$WINEPREFIX" ]
    then
      wine cmd /c dir > /dev/null 2> /dev/null # initialize prefix
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
