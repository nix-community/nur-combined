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
, home ? ""
}:
let
  wineBin = "${wine}/bin/wine${if is64bits then "64" else ""}";
  requiredPackages = with pkgs; [
    wine
    cabextract
  ];
  PATH = pkgs.lib.makeBinPath requiredPackages;
  HOME = if home == "" 
    then "$HOME" 
    else home;
  WINEARCH = if is64bits 
    then "win64" 
    else "win32";
  setupHook = ''
      ${wine}/bin/wineboot
  '';
  tricksHook = if (length tricks) > 0 then
      let
        tricksStr = concatStringsSep " " tricks;
        tricksCmd = ''
        pushd $(mktemp -d)
          wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
          chmod +x winetricks
          ./winetricks ${tricksStr}
        popd
        '';
      in tricksCmd
    else "";
  script = pkgs.writeShellScriptBin name ''
    export WINEARCH=${WINEARCH}
    export WINE_NIX="$HOME/.wine-nix" # define antes de definir $HOME senão ele vai gravar na nova $HOME a .wine-nix
    export PATH=$PATH:${PATH}
    export HOME=${HOME}
    HOME="$(echo ~)"
    export WINEPREFIX="$WINE_NIX/${name}"
    EXECUTABLE="${executable}"
    mkdir -p "$WINE_NIX"
    ${setupScript}
    if [ ! -d "$WINEPREFIX" ]
    then
      ${setupHook}
      # ${wineBin} cmd /c dir > /dev/null 2> /dev/null # initialize prefix
      wineserver -w
      ${tricksHook}
      ${firstrunScript}
    fi
    ${if chdir != null 
      then ''cd "${chdir}"'' 
      else ""}
    if [ ! "$REPL" == "" ];
    then
      bash
      exit 0
    fi

    ${wineBin} ${wineFlags} "$EXECUTABLE" "$@"
    wineserver -w
  '';
in script
