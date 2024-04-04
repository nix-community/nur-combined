{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.cloudflared;
in
{
  disabledModules = [ "services/networking/cloudflared.nix" ];
  options.services.cloudflared = {
    enable = mkEnableOption (lib.mdDoc "Cloudflare Tunnel client daemon (formerly Argo Tunnel)");

    user = mkOption {
      type = types.str;
      default = "cloudflared";
      description = lib.mdDoc "User account under which Cloudflared runs.";
    };

    group = mkOption {
      type = types.str;
      default = "cloudflared";
      description = lib.mdDoc "Group under which cloudflared runs.";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.cloudflared;
      defaultText = "pkgs.cloudflared";
      description = lib.mdDoc "The package to use for Cloudflared.";
    };

    environmentFile = mkOption {
      type = types.str;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.cloudflared-tunnel = ({
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
    });

    users.users = mkIf (cfg.user == "cloudflared") {
      cloudflared = {
        group = cfg.group;
        isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "cloudflared") { cloudflared = { }; };
  };
}
