{ config, lib, ... }:
let
  cfg = config.nixcfg.networking;
in
{
  options.nixcfg.networking.enable = lib.mkEnableOption "networking defaults (networkmanager, nftables)";

  config = lib.mkIf cfg.enable {
    networking = {
      networkmanager.enable = true;
      nftables.enable = true;
    };
  };
}
