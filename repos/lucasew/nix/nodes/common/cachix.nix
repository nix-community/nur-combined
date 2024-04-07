{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs) cachix;
  pathIfExists = import ../../lib/pathListIfExist.nix;
in
{
  imports = pathIfExists /etc/nixos/cachix.nix;
  options.cachix.enable = mkEnableOption "enable cachix";
  config = mkIf config.cachix.enable { environment.systemPackages = [ cachix ]; };
}
