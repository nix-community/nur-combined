{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.prometheus-cheap-switch-exporter;
  settingsFormat = pkgs.formats.yaml { };
in
{
  options.services.prometheus-cheap-switch-exporter = {
    enable = lib.mkEnableOption "Prometheus exporter for cheap switch boxes without SNMP";
    package = lib.mkPackageOption pkgs "cheap-switch-exporter" { };
    port = lib.mkOption {
      type = lib.types.port;
      default = 9632;
      description = ''
        Port to listen on.
      '';
    };
    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = ''
        Address to listen on.
      '';
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Open port in firewall for incoming connections.
      '';
    };
    settings = lib.mkOption {
      description = ''
        Config of cheap-switch-exporter.

        See <https://github.com/pvelati/cheap-switch-exporter/blob/main/config.yaml.example>
        for available options.
      '';
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options = {
          address = lib.mkOption {
            type = lib.types.str;
            default = "192.168.1.1";
            description = ''
              Switch address.
            '';
          };
          username = lib.mkOption {
            type = lib.types.str;
            default = "admin";
            description = ''
              Web-ui username.
            '';
          };
          password = lib.mkOption {
            type = lib.types.str;
            default = "admin";
            description = ''
              Web-ui password.
            '';
          };
          poll_rate_seconds = lib.mkOption {
            type = lib.types.int;
            default = 10;
            description = ''
              Poll rate in seconds.
            '';
          };
          timeout_seconds = lib.mkOption {
            type = lib.types.int;
            default = 10;
            description = ''
              Timeout in seconds.
            '';
          };
          poe = lib.mkOption {
            type = lib.types.int;
            default = 0;
            description = ''
              POE, 1 enable, 0 disable.
            '';
          };
        };
      };
    };
    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/cheap-switch-exporter.yml";
      description = ''
        The config file of cheap-switch-exporter.

        Setting this option will override any configuration applied by the settings option.

        See <https://github.com/pvelati/cheap-switch-exporter/blob/main/config.yaml.example>
        for available options.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
    services.prometheus-cheap-switch-exporter.configFile = lib.mkDefault (
      settingsFormat.generate "config.yml" cfg.settings
    );
    systemd.services.prometheus-cheap-switch-exporter = {
      description = "Prometheus exporter for qBittorrent";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        DynamicUser = true;
        # -port is misleading name, it actually accepts address too
        ExecStart = ''
          ${lib.getExe cfg.package} \
            --config-file=${lib.escapeShellArg cfg.configFile} \
            --web.listen-address=${cfg.listenAddress}:${toString cfg.port}
        '';
        Restart = "always";
      };
    };
  };
}
