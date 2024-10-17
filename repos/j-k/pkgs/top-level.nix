# trimmed down pkgs/top-level/default.nix and pkgs/top-level/stage.nix
{
  pkgs,
  localSystem ? pkgs.system,
  lib ? pkgs.lib,
}:
let
  # need to copy form upstream nixpkgs
  autoCaller = import ./by-name-overlay.nix { inherit lib; };
  autoCalledPackages = autoCaller ./by-name;

  extraPackages = _final: _prev: import ./extra-packages.nix { inherit pkgs; };

  pkgsWithNur = import pkgs.path {
    inherit (pkgs) system;
    overlays = [
      autoCalledPackages
      extraPackages
    ];
  };

  # helper to remove packages for unsupported platforms
  # keep pkgs-lib as it's actually functions
  stripUnavailable = lib.filterAttrs (
    n: drv: if n == "pkgs-lib" then true else builtins.elem localSystem (drv.meta.platforms or [ ])
  );

  # can call packages in the overlay
  resultingOverlay = autoCalledPackages pkgsWithNur pkgs;
in
stripUnavailable resultingOverlay
