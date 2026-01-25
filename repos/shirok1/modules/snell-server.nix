{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.snell-server;
  settingsFormat = pkgs.formats.ini { };
in
{
  options.services.snell-server = {
    enable = lib.mkEnableOption "Enable Snell Proxy Service";

    settings = lib.mkOption {
      type = lib.types.nullOr settingsFormat.type;
      default = null;
      description = "INI settings to write into the configuration file.";
      example = { };
    };

    settingsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Configuration file to be passed directly.
      '';
    };

    package = lib.options.mkPackageOption pkgs "snell-server" { };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          let
            noSettings = cfg.settings == null;
            noSettingsFile = cfg.settingsFile == null;
          in
          (noSettings && !noSettingsFile) || (!noSettings && noSettingsFile);
        message = "Option `settings` or `settingsFile` must be set and cannot be set simultaneously";
      }
    ];

    systemd.services.snell-server = {
      description = "Snell Proxy Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      restartIfChanged = true;

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} -c ${
          if cfg.settingsFile != null then
            cfg.settingsFile
          else
            settingsFormat.generate "snell-server.conf" cfg.settings
        }";
        Restart = "on-failure";
        DynamicUser = true;
        LimitNOFILE = 32768;
      };
    };

    environment = {
      systemPackages = [ cfg.package ];
    };
  };
}
