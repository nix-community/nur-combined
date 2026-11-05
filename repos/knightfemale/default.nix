{
  pkgs,
}:
let
  overlay = import ./outputs/_overlays/default.nix;
  pkgs' = pkgs.extend overlay;
in
{
  overlays.default = overlay;

  inherit (pkgs')
    biu
    comfyui-workflow-mcp
    flake-show-ng
    ;

  legacyPackages = {
    inherit (pkgs')
      deviceTrees
      ;
  };

  nixosModules = {
    openlist = ./outputs/_nixosModules/openlist;
  };

  homeModules = {
    comfyui-workflow-mcp = ./outputs/_homeModules/comfyui-workflow-mcp;
  };
}
