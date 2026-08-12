{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.fastenhealth;
  fastenDbDir = "/var/db/fastenhealth/";
  configfile =
    # THIS WILL END UP IN THE NIX STORE
    # IT IS NOT APPROPRIATE FOR CREDENTIALS
    writeText "fastenhealth.yaml" (toYAML {
        version = 1;
        web = {
          listen = {
            port = cfg.port;
            host = cfg.host;
            # basepath # TODO: base path for proxying
          };
        };
        src = {
          frontend = {
            path = ""; # TODO: where do these files end up?
          };
        };
        database = {
          location = "${fastenDbDir}/fasten.db"; # TODO: custom path
        };
      });
in {
  options.services.fastenhealth = {
    enable = mkEnableOption (mdDoc "Fasten Health self-hosted medical record backups");
    package = mkOption {
      type = types.package;
      default = pkgs.fastenhealth;
      defaultText = literalExpression "pkgs.fastenhealth";
      description = mdDoc "The Fasten Health package to use.";
    };
    openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc ''
          Opens the specified TCP port for Fasten Health.
        '';
      };
    port = mkOption {
      type = types.port;
      default = 8080;
      description = mdDoc ''
          The TCP port which Fasten Health will listen on.
        '';
    };
    host = mkOption {
      type = types.str;
      description = mdDoc "Set the host to bind on.";
      default = "0.0.0.0";
    };
    user = mkOption {
      type = types.str;
      description = mdDoc "Set the user to run under.";
      default = "fastenhealth";
    };
    group = mkOption {
      type = types.str;
      description = mdDoc "Set the group to run under.";
      default = "fastenhealth";
    };
  };
  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };
    systemd.services.fastenhealth = {
      description = "Fasten Health backend + frontend";
      wantedBy = [ "multi-user.target" ];

        #touch "${cfg.stateFile}"
        #touch "${cfg.stateFile}.tmp"

        #mkdir -p "${cfg.ledisDir}";

      preStart = ''
        mkdir -p "$(dirname "${cfg.fastenDbDir}")";
        if [ "$(id -u)" = 0 ]; then
          chown ${cfg.user}:${cfg.group} "${cfg.stateFile}"
        fi
      '';

      serviceConfig = {
        PermissionsStartOnly = true;
        User = cfg.user;
        Group = cfg.group;
        ExecStart = ''
          ${cfg.package}/bin/fasteni start --config ${configFile}
        '';
      };
    };
    environment.etc."fastenhealth.yaml".source = configfile;
  };
  meta = {
    maintainers = with lib.maintainers; [ ProducerMatt ];
    #doc = ./default.md; # TODO
    #buildDocsInSandbox = true;
  };
}
