{
  config,
  lib,
  pkgs,
  ...
}:
let
  commonName = "rustical";
  defaultUser = commonName;
  defaultGroup = commonName;
  cfg = config.services.rustical;
in
{
  options = {
    services.rustical = {
      enable = lib.mkEnableOption "rustical";
      user = lib.mkOption {
        type = lib.types.str;
        default = defaultUser;
        description = ''
          User account under which the web-application run.
        '';
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = defaultGroup;
        description = ''
          Group under which the web-application run.
        '';
      };

      package = lib.mkPackageOption pkgs "rustical" { };

      configFile = lib.mkOption {
        type = lib.types.path;
        description = ''
          Path to the rustical configuration file.
        '';
      };
    };

  };

  config = lib.mkIf cfg.enable {
    systemd.services.rustical = {
      description = "rustical";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = "rustical";
        ExecStart = "${lib.getExe cfg.package} --config-file ${cfg.configFile}";
        Restart = "on-failure";
      };
    };

    users.users.${cfg.user} = lib.mkIf (cfg.user == defaultUser) {
      description = "${commonName} service user";
      isSystemUser = true;
      inherit (cfg) group;
    };

    users.groups.${cfg.group} = lib.mkIf (cfg.group == defaultGroup) { };
  };
}
