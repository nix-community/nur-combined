{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.lfreader;
  lfreaderPkg = pkgs.callPackage ../../pkgs/top-level/lfreader {};
  json = pkgs.formats.json {};
in {
  options.services.lfreader = {
    enable = mkEnableOption "LFReader server";

    package = mkOption {
      type = types.package;
      default = lfreaderPkg;
      defaultText = literalExpression "nur-dcsunset.packages.lfreader";
      description = "Package to use for lfreader (e.g. package from nur)";
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Port to listen at";
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Host address to bind on";
    };

    settings = mkOption {
      type = json.type;
      default = {};
      example = { log_level = "debug"; };
      description = "Config passed to server";
    };

    user = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "User to run the systemd service (`null` means root user)";
    };

    extraOptions = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Additional command-line arguments to pass to lfreader-server";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.lfreader = {
      description = "LFReader server";
      wantedBy = [ "multi-user.target" ];
      environment = {
        LFREADER_CONFIG = json.generate "config.json" cfg.settings;
      };
      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/lfreader-server --host ${cfg.host} --port ${toString cfg.port} \
            ${concatStringsSep " " cfg.extraOptions}
        '';
        NoNewPrivileges = true;
        LockPersonality = true;
        RestrictSUIDSGID = true;
      } // (optionalAttrs (cfg.user != null) {
        User = cfg.user;
      });
    };
  };
}
