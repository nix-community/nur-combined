{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.bloop;
in {
  options = {
    services.bloop.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable Bloop build server.";
    };
  };

  config = mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
    environment.systemPackages = [pkgs.bloop];
    launchd.user.agents.bloop = {
      serviceConfig.ProgramArguments = [ "${pkgs.bloop}/bin/blp-server" ];
      serviceConfig.KeepAlive = true;
      serviceConfig.ProcessType = "Interactive";
    };
  };
  
}
