{ config, pkgs, lib, ... }:
# Mostly thanks to: https://github.com/X01A/nixos/blob/d22772e7870db9c53d24c3b259b1ee983c1455be/modules/network/tailscale/default.nix#L1
with lib;
let
  cfg = config.services.tailscale;
  haveElement = it: (builtins.length it) > 0;
  optionalList = cond: list: if cond then list else [ ];

  tailscaleJoinArgsList =
    [ "-authkey $(cat ${cfg.authFile})" "--login-server" cfg.loginServer ]
    ++ (optionalList (haveElement cfg.advertiseRoutes) [
      "--advertise-routes"
      (builtins.concatStringsSep "," cfg.advertiseRoutes)
    ]) ++ (optionalList cfg.acceptRoute [ "--accept-routes=true" ])
    ++ (optionalList cfg.advertiseExitNode [ "--advertise-exit-node=true" ])
    ++ cfg.extraUpArgs;

  enableForwarding = (haveElement cfg.advertiseRoutes) || cfg.advertiseExitNode;

  tailscaleJoinArgsString = builtins.concatStringsSep " " tailscaleJoinArgsList;
in {
  options = {
    services.tailscale = {
      authFile = mkOption {
        type = types.str;
        example = "/run/keys/TAILSCALE_KEY";
        description = "File location store tailscale auth-key";
      };

      tailnet = mkOption {
        type = types.str;
        default = "general";
        example = "dns";
        description =
          "The tailnet primarily associated with the host. This isn't utilised in the config beyond as a referenceable data point for flake config generation";
      };

      loginServer = mkOption {
        type = types.str;
        default = "https://headscale.rovacsek.com";
        example = "https://headscale.example.com";
        description = "Tailscale login server url";
      };

      advertiseRoutes = mkOption {
        type = with types; listOf str;
        default = [ ];
        example = ''["10.0.0.0/24"]'';
        description = "List of advertise routes";
      };

      acceptRoute = mkOption {
        type = types.bool;
        default = false;
        description = "Accept route when join netowrk";
      };

      advertiseExitNode = mkOption {
        type = types.bool;
        default = false;
      };

      extraUpArgs = mkOption {
        type = with types; listOf str;
        default = [ ];
        description = "Extra args for tailscale up";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ tailscale ];

    # Don't restart tailscale if changed, arovid ssh connection disconnect
    systemd.services.tailscaled.restartIfChanged = false;
    systemd.services.tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";

      # make sure tailscale is running before trying to connect to tailscale
      after = [ "network-pre.target" "tailscale.service" ];
      wants = [ "network-pre.target" "tailscale.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig.Type = "oneshot";
      script = with pkgs; ''
        # wait for tailscaled to settle
        sleep 2

        # check if we are already authenticated to tailscale
        status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then # if so, then do nothing
          exit 0
        fi

        health="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r '.Health | .[0]')"
        if [ $status = "not in map poll" ]; then # reauth the connection
          ${tailscale}/bin/tailscale up ${tailscaleJoinArgsString} --force-reauth
        else
          ${tailscale}/bin/tailscale up ${tailscaleJoinArgsString} --reset
        fi
      '';
    };

    networking.firewall = {
      trustedInterfaces = [ "tailscale0" ];
      checkReversePath = "loose";
      allowedUDPPorts = [ cfg.port ];
    };

    boot.kernel.sysctl = if enableForwarding then {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv4.conf.default.forwarding" = true;
      "net.ipv4.ip_forward" = true;
      "net.ipv6.conf.all.forwarding" = true;
    } else
      { };
  };
}
