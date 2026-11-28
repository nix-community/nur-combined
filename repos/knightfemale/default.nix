{
  pkgs,
}:

let
  overlays = {
    default = import ./outputs/_overlays/default.nix;
    deviceTrees = import ./outputs/_overlays/deviceTrees.nix;
    lib = import ./outputs/_overlays/lib.nix;
    packages = import ./outputs/_overlays/packages.nix;
    python314Packages = import ./outputs/_overlays/python314Packages.nix;
  };

  pkgs' = pkgs.extend overlays.default;

  inherit (pkgs'.lib)
    recurseIntoPackageSets
    ;

  deviceTrees = recurseIntoPackageSets pkgs'.deviceTreesRaw;
  python314Packages = recurseIntoPackageSets pkgs'.python314PackagesRaw;
in
{
  inherit overlays;

  inherit (pkgs')
    biu
    comfyui-workflow-mcp
    flake-show-ng
    lada
    ;

  inherit
    python314Packages
    deviceTrees
    ;

  nixosModules = {
    openlist = ./outputs/_nixosModules/openlist;
  };

  homeModules = {
    comfyui-workflow-mcp = ./outputs/_homeModules/comfyui-workflow-mcp;
    lada = ./outputs/_homeModules/lada;
  };
}
