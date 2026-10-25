# Makes every NUR kernel module available as config.boot.kernelPackages.<name>,
# built against the configured kernel (including boot.kernelPatches).
#
# Read-only pkgs (nixpkgs.pkgs, e.g. pkgs.testers.runNixOSTest nodes) cannot
# take overlays; apply overlays.kernel-modules where that pkgs is constructed.
{ lib, options, ... }:
{
  config = lib.mkIf (!options.nixpkgs.pkgs.isDefined) {
    nixpkgs.overlays = [ (import ../overlays).kernel-modules ];
  };
}
