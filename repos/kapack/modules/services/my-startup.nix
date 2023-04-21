{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.my-startup;
in
{

  ###### interface
  
  meta.maintainers = [];

  options = {
    services.my-startup = {

      enable = mkEnableOption "My startup ";
      
      script =  mkOption {
          type = types.str;
          default = "/etc/my-startup.sh";
          description = "Script File to execute a start time";
      };

      path =  mkOption {
        type = types.path;
        default = [ ];
        description = "Path to tools used by provided script";
      };
      
    };
  };

  ###### implementation
  
  config =  mkIf ( cfg.enable)  {
    systemd.services.my-startup = {
      description = "My startup";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target"];
      path = cfg.path;
      serviceConfig.Type = "oneshot";
      script = cfg.script;
    };
  };
}
