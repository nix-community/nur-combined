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
      type = settingsFormat.type;
      default = { };
      description = "INI settings to write into the configuration file.";
      example = { };
    };

    package = lib.options.mkPackageOption pkgs "snell-server" { };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.snell-server = {
      description = "Snell Proxy Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      restartIfChanged = true;

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} -c ${settingsFormat.generate "snell-server.conf" cfg.settings}";
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
