{ config, lib, pkgs, ... }:

let
  cfg = config.services.mattsRemoteAccess;
in
{
  options.services.mattsRemoteAccess = with lib; {
    enable = mkEnableOption "Enable remote desktop server";
    type = mkOption {
      description = "Which type of remote desktop service to use. Currently only RDP";
      type = with types; strMatching "RDP";
      default = "RDP";
    };
    defaultWindowManager = mkOption {
      description = "How to start the Window Manager";
      type = with types; str;
      default = "startplasma-x11";
    };
    port = mkOption {
      description = "Port to listen on.";
      type = with types; uniq port;
      default = 3389;
    };
  };
  config = with lib; mkIf
    (cfg.enable &&
      (cfg.defaultWindowManager == "RDP"))
    {
      services.xrdp.enable = true;
      services.xrdp.defaultWindowManager = cfg.defaultWindowManager;
      networking.firewall.allowedTCPPorts = [ cfg.port ];
    };
}
