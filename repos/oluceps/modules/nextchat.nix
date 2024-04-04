{
  pkgs,
  config,
  user,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.nextchat;
in
{
  options.services.nextchat = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    workDir = mkOption {
      type = types.str;
      default = "/home/${user}/Src/ChatGPT-Next-Web";
    };
    environmentFile = mkOption {
      type = types.str;
      default = config.age.secrets.nextchat.path;
    };
  };
  config = mkIf cfg.enable {
    systemd.services.nextchat = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      description = "nextchat Daemon";

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        RootDirectory = cfg.workDir;
        ExecStart = "${lib.getExe pkgs.yarn} start";
        EnvironmentFile = cfg.environmentFile;
        Restart = "on-failure";
      };
    };
  };
}
