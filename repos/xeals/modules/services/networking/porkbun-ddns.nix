{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption types;

  cfg = config.services.porkbun-ddns;
in
{
  options = {
    services.porkbun-ddns = {
      enable = lib.mkEnableOption "Porkbun dynamic DNS client";

      package = mkOption {
        # TODO: How do I use mkPackageOption when the package isn't in the
        #  package set?
        type = types.package;
        default = pkgs.callPackage ../../../pkgs/by-name/po/porkbun-ddns/package.nix { };
        defaultText = "pkgs.porkbun-ddns";
        description = lib.mdDoc "The porkbun-ddns package to use.";
      };

      interval = mkOption {
        type = types.str;
        default = "10m";
        description = lib.mdDoc ''
          Interval to update dynamic DNS records. The default is to update every
          10 minutes. The format is described in {manpage}`systemd.time(7)`.
        '';
      };

      domains = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = lib.mdDoc "Domains to update.";
      };

      apiKeyFile = mkOption {
        type = types.nullOr types.path;
        description = lib.mdDoc ''
          File containing the API key to use when running the client.
        '';
      };

      secretApiKeyFile = mkOption {
        type = types.nullOr types.path;
        description = lib.mdDoc ''
          File containing the secret API key to use when running the
          client.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.porkbun-ddns = {
      description = "Porkbun dynamic DNS client";
      script = ''
        ${cfg.package}/bin/porkbun-ddns \
          -K ${cfg.apiKeyFile} \
          -S ${cfg.secretApiKeyFile} \
          ${lib.concatStringsSep " " cfg.domains}
      '';
    };

    systemd.timers.porkbun-ddns = {
      description = "Porkbun dynamic DNS client";
      wants = [ "network-online.target" ];
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = cfg.interval;
        OnUnitActiveSec = cfg.interval;
      };
    };
  };
}
