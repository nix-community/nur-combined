{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.irc-link-informant;
in
{
  options.services.irc-link-informant = {
    enable = mkEnableOption "irc-link-informant";
    config = mkOption {
      type = types.str;
      example = ''
        channel = "#linux"
        server = "irc.libera.chat:6667"
        nick = "TheAdultInTheRoom"
        name = "AdultName"
        user = "AdultUser"
      '';
    };
    user = mkOption {
      type = types.str;
      default = "irc-link-informant";
    };
    group = mkOption {
      type = types.str;
      default = "irc-link-informant";
    };
  };
  config = mkIf cfg.enable {
    users = {
      groups.${cfg.group} = { };
      users.${cfg.user} = {
        createHome = false;
        group = cfg.group;
        isSystemUser = true;
      };
    };
    systemd.services.irc-link-informant = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
      description = "runs irc-link-informant";
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "1 min";
        ExecStart = "${pkgs.myPackages.irc-link-informant}/bin/link_informant";
        WorkingDirectory = "${(pkgs.writeTextFile {
          name = "irc-link-informant-config";
          destination = "/workdir/Settings.toml";
          text = cfg.config;
        })}/workdir";
        User = cfg.user;
        Group = cfg.group;
      };
    };
  };
}
