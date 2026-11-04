{
  pkgs,
}:
let
  inherit (pkgs) lib;
  overlay = import ./outputs/_overlays/default.nix { inherit lib; };
  pkgs' = pkgs.extend overlay;
  platform = pkgs'.stdenv.hostPlatform;
  inherit (platform)
    isAarch64
    isLinux
    ;
in
{
  overlays.default = overlay;

  inherit (pkgs')
    comfyui-workflow-mcp
    flake-show-ng
    ;

  legacyPackages = lib.optionalAttrs (isAarch64 && isLinux) {
    inherit (pkgs')
      deviceTrees
      ;
  };

  nixosModules = {
    openlist = import ./outputs/_nixosModules/openlist;
  };

  homeModules = {
    comfyui-workflow-mcp = import ./outputs/_homeModules/comfyui-workflow-mcp;
  };
}
// lib.optionalAttrs isLinux {
  inherit (pkgs')
    biu
    ;
}
