{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.barrier;
in
{
  options = {
    services.barrier = {
      enable = mkEnableOption ''
        Barrier is a software kvm
      '';
    };
  };
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 24800 ];
  };
}
