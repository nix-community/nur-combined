{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.cloudflared;
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;
in
{
  disabledModules = [ "services/networking/cloudflared.nix" ];
  options.services.cloudflared = {
    enable = mkEnableOption "Cloudflare Tunnel client daemon (formerly Argo Tunnel)";

    user = mkOption {
      type = types.str;
      default = "cloudflared";
      description = "User account under which Cloudflared runs.";
    };

    group = mkOption {
      type = types.str;
      default = "cloudflared";
      description = "Group under which cloudflared runs.";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.cloudflared;
      defaultText = "pkgs.cloudflared";
      description = "The package to use for Cloudflared.";
    };

    environmentFile = mkOption {
      type = types.str;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.cloudflared-tunnel = {
      after = [
        "network.target"
        "network-online.target"
      ];
      wants = [
        "network.target"
        "network-online.target"
      ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        EnvironmentFile = cfg.environmentFile;
        ExecStart = "${cfg.package}/bin/cloudflared --no-autoupdate tunnel run --token $TOKEN";
        Restart = "on-failure";
      };
    };

    users.users = mkIf (cfg.user == "cloudflared") {
      cloudflared = {
        inherit (cfg) group;
        isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "cloudflared") { cloudflared = { }; };
  };
}
