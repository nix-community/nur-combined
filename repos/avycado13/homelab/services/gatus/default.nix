{
  config,
  lib,
  ...
}:
let
  cfg = config.homelab.services.gatus;
  hl = config.homelab;
  port = 8087;

  toEndpoint = name: svc: {
    name = svc.glance.name or name;
    inherit (svc.gatus) url interval;
    conditions = [ svc.gatus.condition ];
  };
  endpoints =
    (lib.pipe hl.services [
      (lib.filterAttrs (
        name: svc:
        name != "gatus" && lib.isAttrs svc && (svc.enable or false) && (svc.gatus or null) != null
      ))
      (lib.mapAttrsToList toEndpoint)
    ])
    ++ lib.optionals hl.services.cloudrun.enable (
      lib.mapAttrsToList toEndpoint (
        lib.filterAttrs (_: svc: svc.gatus != null) hl.services.cloudrun.services
      )
    );
in
{
  options.homelab.services.gatus = {
    enable = lib.mkEnableOption "Gatus status page";
    url = lib.mkOption {
      type = lib.types.str;
      default = "status.${hl.baseDomainName}";
      description = "Domain to serve Gatus on";
    };
    glance.name = lib.mkOption {
      type = lib.types.str;
      default = "Gatus";
    };
    glance.url = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "https://${cfg.url}";
      description = "URL to show for this service in the Glance homelab bookmarks";
    };
  };

  config = lib.mkIf cfg.enable {
    services.gatus = {
      enable = true;
      settings = {
        web = {
          address = "127.0.0.1";
          inherit port;
        };
        inherit endpoints;
      };
    };

    systemd.services.gatus.unitConfig.OnFailure = lib.mkIf (
      hl.notifications.ntfySecretsFile != null
    ) "notify-failure@%n.service";

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = hl.acmeHostFor cfg.url;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString port}
      '';
    };
  };
}
