{ pkgs
, lib
, config
, ...
}:
let
  cfg = config.networking.upnp;

  script =
    let
      tcpPorts = lib.concatStringsSep " " (map (port: "${toString port} TCP") cfg.forward.tcpPorts);
      udpPorts = lib.concatStringsSep " " (map (port: "${toString port} UDP") cfg.forward.udpPorts);
    in
    pkgs.writeShellScript "upnpc-port-forwarding.sh" ''
      set -euo pipefail
      IFS=$'\n\t'

      # Exit early if the interface is down
      ${pkgs.iproute2}/bin/ip addr show "$1" | grep -q 'state UP' || exit 0

      ${lib.concatStringsSep "\n" (map (port: ''
          ${pkgs.miniupnpc}/bin/upnpc -d ${toString port} TCP || true
        '')
        cfg.forward.tcpPorts)}
      ${lib.concatStringsSep "\n" (map (port: ''
          ${pkgs.miniupnpc}/bin/upnpc -d ${toString port} UDP || true
        '')
        cfg.forward.udpPorts)}
      exec ${pkgs.miniupnpc}/bin/upnpc -r ${tcpPorts} ${udpPorts}
    '';
in
{
  options.networking.upnp = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable UPnP support for automatic port forwarding.";
    };
    forward = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default =
          ((builtins.length cfg.forward.ifaces) > 0)
          && ((builtins.length cfg.forward.tcpPorts) + (builtins.length cfg.forward.udpPorts)) > 0;
        description = "Enable automatic UPnP port forwarding.";
      };
      updateInterval = lib.mkOption {
        type = lib.types.str;
        default = "15m";
        description = "Interval for the UPnP port forwarding refresh timer.";
      };
      ifaces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ config.hostConfig.primaryNetIface ];
        description = "List of network ifaces to enable UPnP on.";
      };
      tcpPorts = lib.mkOption {
        type = lib.types.listOf lib.types.ints.u16;
        default = [ ];
        description = "List of TCP ports to forward via UPnP.";
      };
      udpPorts = lib.mkOption {
        type = lib.types.listOf lib.types.ints.u16;
        default = [ ];
        description = "List of UDP ports to forward via UPnP.";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.forward.enable && config.networking.nftables.enable) {
      networking.nftables.ruleset = ''
        table inet nixos-fw {
          # Create a set to track the source ports we use for SSDP discovery
          # This set will automatically remove ports after the timeout expires
          set ssdp-source-ports {
            type inet_service    # Store only port numbers, not IP addresses
            flags timeout        # Enable automatic expiration of entries
          }

          chain output {
            type filter hook output priority filter; policy accept;

            # When we send a SSDP discovery packet:
            # - Match packets going to the SSDP multicast address on port 1900.
            # - Extract the source port we're using for this discovery.
            # - Add that source port to our tracking set, with a 5s expiration timeout.
            ip daddr 239.255.255.250 udp dport 1900 add @ssdp-source-ports {udp sport timeout 5s}
          }

          chain input-allow {
            # For incoming packets:
            # - Check if the destination port matches one of our tracked SSDP source ports.
            # - If it matches, accept the packet (allow the UPnP device's response).
            udp dport @ssdp-source-ports accept comment "Allow UPnP/SSDP responses"
          }
        }'';
    })
    (lib.mkIf cfg.forward.enable (
      let
        inherit (cfg.forward) ifaces tcpPorts udpPorts;
      in
      {
        warnings = lib.mkMerge [
          (lib.mkIf
            (tcpPorts == [ ] && udpPorts == [ ])
            "networking.upnp.forward is enabled, but no ports are specified to forward.")
          (lib.mkIf
            (ifaces == [ ])
            "networking.upnp.forward is enabled, but no interfaces are specified to forward on.")
        ];

        systemd = lib.mkIf (tcpPorts != [ ] || udpPorts != [ ]) {
          services = {
            "upnpc@" = {
              description = "UPnP Port Forwarding Service for interface %I";
              after = [ "network.target" ];
              serviceConfig = {
                Type = "oneshot";
                ExecStart = ''${script} %I'';
                RestrictAddressFamilies = lib.mkForce [ "AF_INET" "AF_NETLINK" ];
                RestrictNetworkIfaces = "%I";
              };
            };
          };
          timers = builtins.listToAttrs (map
            (iface: {
              enable = true;
              name = "upnpc@${iface}";
              value = {
                description = "UPnP Port Forwarding Timer for interface %I";
                after = [ "network.target" ];
                wants = [ "network.target" ];
                timerConfig = {
                  OnBootSec = "1min";
                  OnUnitActiveSec = cfg.forward.updateInterval;
                  Persistent = true;
                };
                wantedBy = [ "timers.target" ];
              };
            })
            ifaces);
        };
      }
    ))
  ];
}
