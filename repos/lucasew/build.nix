let
  inherit (builtins) getFlake;
  flake = getFlake "${toString ./.}";
  inherit (flake.outputs) pkgs;
in builtins.attrValues {
  inherit (pkgs)
    stremio
    minecraft
    discord
  ;
  inherit (pkgs.python3Packages)
    scikitlearn
  ;
  inherit (pkgs.wineApps)
    wine7zip
    pinball
  ;
  polybar = pkgs.callPackage ./modules/polybar/customPolybar.nix {};
}
