{ lib, pkgs, config, ... }:
let
  cfg = config.services.fiche;
in
{
  options.services.fiche = {
    enable = lib.mkEnableOption "Enable fiche’s service";
    port = lib.mkOption {
      type = lib.types.port;
      description = "Port to listen to";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Domain";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/fiche";
      description = "Directory where to place the pastes";
    };
    https = lib.mkEnableOption "Use https";
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ cfg.port ];


    system.activationScripts.fiche = ''
      mkdir -p /var/lib/fiche
    '';
    systemd.services.fiche = {
      description = "Fiche server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      script = ''
        exec ${pkgs.fiche}/bin/fiche -o ${cfg.dataDir} -d ${cfg.domain} ${lib.optionalString cfg.https "-S "} -p ${builtins.toString cfg.port}
      '';

      serviceConfig = {
        ExecStartPre = [
          "+${pkgs.coreutils}/bin/install -m 0755 -o fiche -d /var/lib/fiche"
        ];
        DynamicUser = true;
        User = "fiche";
        PrivateTmp = true;
        Restart = "always";
        WorkingDirectory = cfg.dataDir;
        ReadWritePaths = cfg.dataDir;
      };
    };
  };
}
