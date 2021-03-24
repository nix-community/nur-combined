with builtins;
{pkgs}:
{
  wine ? pkgs.wine
  , wineFlags ? ""
  , executable
  , name
  , tricks ? []
  , setupScript ? ""
}:
let
  script = pkgs.writeShellScriptBin name ''
    HOME="$(echo ~)"
    WINE_NIX="$HOME/.wine-nix"
    export WINEPREFIX="$WINE_NIX/${name}"
    ${setupScript}
    mkdir -p "$WINE_NIX"
    if [ ! -d "$WINEPREFIX" ]
    then
      ${pkgs.winetricks}/bin/winetricks ${builtins.concatStringsSep " " tricks}
    fi
    ${wine}/bin/wine ${wineFlags} "${executable}" "$@"
  '';
in script
