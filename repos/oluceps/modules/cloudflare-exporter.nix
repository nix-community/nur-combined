{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types mkIf;

  cfg = config.services.cloudflare-exporter;
in
{
  options.services.cloudflare-exporter = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    listen = mkOption {
      type = types.str;
      default = ":9213";
    };
    environmentFile = mkOption {
      type = types.str;
    };
  };
  config = mkIf cfg.enable {
    systemd.services.cloudflare-exporter = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      description = "cloudflare-exporter Daemon";

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        ExecStart = "${lib.getExe pkgs.prometheus-cloudflare-exporter} --listen=${cfg.listen} --cf_api_token=$CF_API_TOKEN";
        EnvironmentFile = cfg.environmentFile;
        Restart = "on-failure";
      };
    };
  };
}
