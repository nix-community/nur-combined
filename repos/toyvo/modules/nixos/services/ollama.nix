{ config, lib, ... }:
let
  cfg = config.services.ollama;
in
{
  config = lib.mkIf cfg.enable {
    services.ollama = {
      host = "0.0.0.0";
      openFirewall = lib.mkDefault true;
    };
    networking.firewall = {
      allowedTCPPorts = [ cfg.port ];
    };
  };
}
