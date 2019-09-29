{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.bloop;
in {
  options = {
    services.bloop.install = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable Bloop build server.";
    };
  };

  config = mkIf (cfg.install && pkgs.stdenv.isDarwin) {
    environment.systemPackages = with pkgs; [ bloop adoptopenjdk-bin ];
    launchd.user.agents.bloop = {
      environment = {
        JAVA_HOME = "${pkgs.adoptopenjdk-bin}";
      };
      serviceConfig.ProgramArguments = [ "${pkgs.bloop}/blp-server" ];
      serviceConfig.KeepAlive = true;
      serviceConfig.ProcessType = "Interactive";
    };
  };
  
}
