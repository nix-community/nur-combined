{ config, lib, ... }:
let
  cfg = config.sane.programs.sm64ex-coop;
in
{
  sane.programs.sm64ex-coop = {
  };

  networking.firewall.allowedUDPPorts = lib.mkIf cfg.enabled [ 2345 ];
}
