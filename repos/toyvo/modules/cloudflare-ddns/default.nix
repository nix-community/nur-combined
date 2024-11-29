{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.cloudflare-ddns;
  cloudflare-ddns = pkgs.callPackage ../../pkgs/cloudflare-ddns { };
in
{
  options.services.cloudflare-ddns = {
    enable = lib.mkEnableOption "enable cloudflare ddns";
    records = lib.mkOption {
      type = lib.types.listOf lib.types.string;
      default = [ ];
    };
    tokenFile = lib.mkOption {
      type = lib.types.path;
      description = "Cloudflare API token file";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.cloudflare-ddns = {
      description = "CloudFlare Dynamic DNS Client";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      startAt = "*:0/5";
      serviceConfig = {
        Type = "simple";
        LoadCredential = "CLOUDFLARE_API_TOKEN_FILE:${cfg.tokenFile}";
        DynamicUser = true;
      };
      script = ''
        export CLOUDFLARE_API_TOKEN=$(${pkgs.systemd}/bin/systemd-creds cat CLOUDFLARE_API_TOKEN_FILE)
        ${lib.getExe cloudflare-ddns} ${lib.escapeShellArgs cfg.records}
      '';
    };
  };
}
