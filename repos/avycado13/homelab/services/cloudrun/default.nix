{ config, lib, ... }:
let
  hl = config.homelab;
  cfg = hl.services.cloudrun;

  cloudRunServiceModule =
    { name, config, ... }:
    {
      options = {
        cloudRunHost = lib.mkOption {
          type = lib.types.str;
          description = "Cloud Run hostname to proxy to, e.g. service1-name-<hash>.<region>.run.app";
        };
        url = lib.mkOption {
          type = lib.types.str;
          default = "${name}.${hl.baseDomainName}";
          description = "Domain to serve this Cloud Run service on";
        };
        glance.name = lib.mkOption {
          type = lib.types.str;
          default = name;
        };
        glance.url = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = "https://${config.url}";
          description = "URL to show for this service in the Glance homelab bookmarks";
        };
      };
    };
in
{
  options.homelab.services.cloudrun = {
    enable = lib.mkEnableOption "Reverse-proxying Google Cloud Run services through Caddy";
    services = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule cloudRunServiceModule);
      default = { };
      description = "Cloud Run services to expose under baseDomainName";
    };
  };

  config = lib.mkIf cfg.enable {
    services.caddy.virtualHosts = lib.mapAttrs' (
      _: svc:
      lib.nameValuePair svc.url {
        useACMEHost = hl.baseDomainName;
        extraConfig = ''
          reverse_proxy https://${svc.cloudRunHost} {
            header_up Host ${svc.cloudRunHost}
          }
        '';
      }
    ) cfg.services;
  };
}
