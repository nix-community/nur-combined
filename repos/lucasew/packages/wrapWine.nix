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
  WINENIX_PROFILES = "$HOME/WINENIX_PROFILES";
  PATH = pkgs.lib.makeBinPath requiredPackages;
  NAME = name;
  HOME = if home == "" 
    then "${WINENIX_PROFILES}/${name}" 
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
    export APP_NAME="${NAME}"
    export WINEARCH=${WINEARCH}
    export WINE_NIX="$HOME/.wine-nix" # define antes de definir $HOME senão ele vai gravar na nova $HOME a .wine-nix
    export WINE_NIX_PROFILES="${WINENIX_PROFILES}"
    export PATH=$PATH:${PATH}
    export HOME="${HOME}"
    mkdir -p "$HOME"
    export WINEPREFIX="$WINE_NIX/${name}"
    export EXECUTABLE="${executable}"
    mkdir -p "$WINE_NIX" "$WINE_NIX_PROFILES"
    ${setupScript}
    if [ ! -d "$WINEPREFIX" ] # if the prefix does not exist
    then
      ${setupHook}
      # ${wineBin} cmd /c dir > /dev/null 2> /dev/null # initialize prefix
      wineserver -w
      ${tricksHook}
      ${firstrunScript}
      rm "$WINEPREFIX/drive_c/users/$USER" -rf
      ln -s "$HOME" "$WINEPREFIX/drive_c/users/$USER"
    fi
    ${if chdir != null 
      then ''cd "${chdir}"'' 
      else ""}
    if [ ! "$REPL" == "" ]; # if $REPL is setup then start a shell in the context
    then
      bash
      exit 0
    fi

    ${wineBin} ${wineFlags} "$EXECUTABLE" "$@"
    wineserver -w
  '';
in script
