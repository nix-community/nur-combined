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
  tricksStmt = if (length tricks) > 0 then
    concatStringsSep " " tricks
  else
    "-V";
  script = pkgs.writeShellScriptBin name ''
    HOME="$(echo ~)"
    WINE_NIX="$HOME/.wine-nix"
    export WINEPREFIX="$WINE_NIX/${name}"
    ${setupScript}
    mkdir -p "$WINE_NIX"
    if [ ! -d "$WINEPREFIX" ]
    then
      ${pkgs.winetricks}/bin/winetricks ${tricksStmt}
    fi
    ${wine}/bin/wine ${wineFlags} "${executable}" "$@"
  '';
in script
