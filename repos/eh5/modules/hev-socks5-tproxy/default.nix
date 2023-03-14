{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.hev-socks5-tproxy;
  configFormat = pkgs.formats.yaml { };
  configFile =
    if cfg.configFile != null
    then cfg.configFile
    else configFormat.generate "hev-socks5-tproxy.yml" cfg.config;
in
{
  options.services.hev-socks5-tproxy = {
    enable = mkEnableOption "hev-socks5-tproxy service";
    package = mkPackageOption pkgs "hev-socks5-tproxy" { default = [ "hev-socks5-tproxy" ]; };
    configFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "The absolute path to the configuration file.";
    };
    config = mkOption {
      type = configFormat.type;
      default = { };
      description = "The configuration attribute set.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = (cfg.configFile != null) -> (cfg.config == { });
      message = "Either but not both `configFile` and `config` should be specified for hev-socks5-tproxy.";
    }];

    systemd.services.hev-socks5-tproxy = {
      description = "hev-socks5-tproxy Daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      restartTriggers = [ configFile ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/hev-socks5-tproxy ${configFile}";
      };
    };

    environment.systemPackages = [ cfg.package ];
  };
}
