{ config, lib, pkgs, ... }:
let
  cfg = config.services.cloudflared-stateless;
in
{
  options = {
    services.cloudflared-stateless = {
      enable = lib.mkEnableOption (lib.mdDoc "Cloudflare Tunnel client daemon (formerly Argo Tunnel)");
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.cloudflared;
        defaultText = "pkgs.cloudflared";
        description = lib.mdDoc "The package to use for Cloudflared.";
      };
      tunnels = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
          options = {
            environmentFile = lib.mkOption {
              type = with lib.types; nullOr path;
              default = null;
              description = lib.mdDoc ''
                Environment file as defined in {manpage}`systemd.exec(5)`.

                See [Cloudflare documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/install-and-setup/tunnel-guide/local/local-management/arguments/) for available values.
              '';
            };
            token = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
              description = lib.mdDoc ''
                Associates the cloudflared instance with a specific tunnel.
                The tunnel’s token is shown in the dashboard when you first create the tunnel. You can also retrieve the token using the API.

                See [Cloudflare documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/install-and-setup/tunnel-guide/local/local-management/arguments/#token) for more info.
              '';
            };
          };
        }));
        default = { };
        description = lib.mdDoc ''
          Cloudflare tunnels.
        '';
        example = {
          my-tunnel = {
            token = "...";
          };
        };
      };
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services =
      lib.mapAttrs'
        (name: tunnel:
          lib.nameValuePair "cloudflared-stateless-tunnel-${name}" ({
            after = [ "network.target" "network-online.target" ];
            wants = [ "network.target" "network-online.target" ];
            wantedBy = [ "multi-user.target" ];
            environment = lib.mkIf (tunnel.token != null) {
              TUNNEL_TOKEN = tunnel.token;
            };
            serviceConfig = {
              EnvironmentFile = lib.mkIf (tunnel.environmentFile != null) tunnel.environmentFile;
              ExecStart = "${cfg.package}/bin/cloudflared tunnel --no-autoupdate run";
              Restart = "on-failure";
              RestartSec = "5s";
              DynamicUser = true;
              Group = "cloudflared-stateless";
              User = "cloudflared-stateless";
              StateDirectory = "cloudflared-stateless";
              WorkingDirectory = "/var/lib/cloudflared-stateless";
            };
            unitConfig.StartLimitIntervalSec = 0;
          })
        )
        cfg.tunnels;
  };
}
