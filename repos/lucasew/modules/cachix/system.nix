{pkgs, config, lib, ...}:
with lib;
let
  pathIfExists = import ../../lib/pathListIfExist.nix;
in
{
  imports = pathIfExists /etc/nixos/cachix.nix;
  options.cachix.enable = mkEnableOption "enable cachix";
  config = mkIf config.cachix.enable {
    environment.systemPackages = with pkgs; [
      cachix
    ];
  };
}
