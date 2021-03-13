{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.trojan;
in
{

  options.services.trojan = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable trojan service.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.nur.repos.linyinfeng.trojan;
      defaultText = "pkgs.nur.repos.linyinfeng.trojan";
      description = ''
        trojan derivation to use.
      '';
    };

    config = mkOption {
      type = types.nullOr types.attrs;
      default = null;
      description = ''
        configuration for trojan service.
      '';
    };

    configFile = mkOption
      {
        type = types.nullOr types.path;
        default = null;
        description = ''
          configuration file for trojan service.
        '';
      };

    extraOptions = mkOption {
      type = types.separatedString " ";
      default = "";
      example = "--log LOG_FILE_PATH";
      description = ''
        extra command line options for trojan service.
      '';
    };
  };

  config =
    let
      configFile =
        if cfg.configFile != null
        then cfg.configFile
        else
          pkgs.writeTextFile {
            name = "trojan.json";
            text = builtins.toJSON cfg.config;
            checkPhase = ''
              ${cfg.package}/bin/trojan --test --config $out
            '';
          };
    in
    mkIf (cfg.enable) {
      assertions = [
        {
          assertion = (cfg.configFile == null) != (cfg.config == null);
          message = "Either but not both `configFile` and `config` should be specified for trojan.";
        }
      ];
      systemd.services.trojan =
        {
          description = "An unidentifiable mechanism that helps you bypass GFW";

          serviceConfig = {
            Type = "simple";
            StandardError = "journal";
            User = "nobody";
            AmbientCapabilities = "CAP_NET_BIND_SERVICE";
            ExecStart = "${cfg.package}/bin/trojan --config ${configFile} ${cfg.extraOptions}";
            ExecReload = "${pkgs.util-linux}/bin/kill -HUP $MAINPID";
            Restart = "on-failure";
            RestartSec = "1s";
          };

          wantedBy = [ "multi-user.target" ];
        };

      environment.systemPackages = [
        cfg.package
      ];
    };
}
