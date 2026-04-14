{
  config,
  lib,
  homelab,
  ...
}:
let
  cfg = config.containerPresets.starr;
  vpnInterface = "wg-proton";
  vpnNamespace = "protonvpn0";
in
{
  options.containerPresets.starr = {
    enable = lib.mkEnableOption "Starr suite NixOS container";

    hostAddress = lib.mkOption {
      type = lib.types.str;
      description = "Host side of the veth pair";
    };

    localAddress = lib.mkOption {
      type = lib.types.str;
      description = "Container IP address";
    };

    natInterface = lib.mkOption {
      type = lib.types.str;
      description = "Host LAN-facing network interface for NAT masquerade (e.g. eno1, enp2s0). Discover with: ip route get 1.1.1.1";
    };

    stateDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/nixos-containers/starr";
      description = "Base directory containing per-service state subdirectories";
    };

    mediaDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/nixos-containers/starr";
      description = "Media pool path bind-mounted read-write into the container at /mnt";
    };

    multimediaGid = lib.mkOption {
      type = lib.types.int;
      default = 349;
      description = "Pinned GID for the multimedia group on both host and container";
    };

    bazarrUid = lib.mkOption {
      type = lib.types.int;
      default = 350;
      description = "Pinned UID for the bazarr user (must match state dir ownership on host)";
    };

    prowlarrUid = lib.mkOption {
      type = lib.types.int;
      default = 351;
      description = "Pinned UID for the prowlarr user (must match state dir ownership on host; prowlarr uses DynamicUser upstream so this is required)";
    };

    readarrUid = lib.mkOption {
      type = lib.types.int;
      default = 352;
      description = "Pinned UID for the readarr user (must match state dir ownership on host)";
    };

    qbittorrentUid = lib.mkOption {
      type = lib.types.int;
      default = 353;
      description = "Pinned UID for the qbittorrent user (must match state dir ownership on host)";
    };

    protonvpn = {
      privateKeyFile = lib.mkOption {
        type = lib.types.path;
        description = "Path to the ProtonVPN WireGuard private key file on the host (decrypted by sops; bind-mounted read-only into the container)";
      };

      publicKey = lib.mkOption {
        type = lib.types.str;
        description = "ProtonVPN WireGuard peer public key";
      };

      endpoint = lib.mkOption {
        type = lib.types.str;
        description = "ProtonVPN WireGuard server endpoint (host:port)";
      };

      ip = lib.mkOption {
        type = lib.types.str;
        default = "10.2.0.2/32";
        description = "WireGuard IP assigned by ProtonVPN";
      };

      gateway = lib.mkOption {
        type = lib.types.str;
        default = "10.2.0.1";
        description = "ProtonVPN gateway IP (used for DNS inside the VPN namespace and NAT-PMP port forwarding)";
      };
    };

    qbittorrent = {
      serverConfig = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Extra settings merged into qbittorrent's config file (LegalNotice.Accepted is always set)";
      };
    };

    ports = {
      bazarr = lib.mkOption {
        type = lib.types.port;
        default = homelab.starr.services.bazarr.port;
        description = "Bazarr listen port";
      };
      flaresolverr = lib.mkOption {
        type = lib.types.port;
        default = homelab.starr.services.flaresolverr.port;
        description = "FlareSolverr listen port";
      };
      lidarr = lib.mkOption {
        type = lib.types.port;
        default = homelab.starr.services.lidarr.port;
        description = "Lidarr listen port";
      };
      prowlarr = lib.mkOption {
        type = lib.types.port;
        default = homelab.starr.services.prowlarr.port;
        description = "Prowlarr listen port";
      };
      qbittorrent = lib.mkOption {
        type = lib.types.port;
        default = homelab.starr.services.qbittorrent.port;
        description = "qBittorrent web UI listen port";
      };
      radarr = lib.mkOption {
        type = lib.types.port;
        default = homelab.starr.services.radarr.port;
        description = "Radarr listen port";
      };
      readarr = lib.mkOption {
        type = lib.types.port;
        default = homelab.starr.services.readarr.port;
        description = "Readarr listen port";
      };
      sonarr = lib.mkOption {
        type = lib.types.port;
        default = homelab.starr.services.sonarr.port;
        description = "Sonarr listen port";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.monitoring.containerJournals = [ "starr" ];
    # Pin multimedia GID so bind-mounted paths are accessible from inside the container
    users.groups.multimedia.gid = cfg.multimediaGid;

    # NAT masquerade so the container can reach external indexers (Prowlarr, FlareSolverr)
    networking.nat = {
      enable = true;
      externalInterface = cfg.natInterface;
      internalInterfaces = [ "ve-starr" ];
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/nixos-containers/starr/var/log/journal 0755 root systemd-journal -"
    ];

    containers.starr = {
      autoStart = true;
      extraFlags = [ "--link-journal=guest" ];
      privateNetwork = true;
      hostAddress = cfg.hostAddress;
      localAddress = cfg.localAddress;

      # Required for WireGuard interface and network namespace creation inside the container
      additionalCapabilities = [ "CAP_NET_ADMIN" ];

      bindMounts = {
        "/mnt" = {
          hostPath = cfg.mediaDir;
          isReadOnly = false;
        };
        # ProtonVPN key decrypted by sops on the host, made available read-only inside
        "/run/secrets/protonvpn.key" = {
          hostPath = cfg.protonvpn.privateKeyFile;
          isReadOnly = true;
        };
        "/var/lib/bazarr" = {
          hostPath = "${cfg.stateDir}/bazarr";
          isReadOnly = false;
        };
        "/var/lib/lidarr" = {
          hostPath = "${cfg.stateDir}/lidarr";
          isReadOnly = false;
        };
        "/var/lib/prowlarr" = {
          hostPath = "${cfg.stateDir}/prowlarr";
          isReadOnly = false;
        };
        "/var/lib/qBittorrent" = {
          hostPath = "${cfg.stateDir}/qbittorrent";
          isReadOnly = false;
        };
        "/var/lib/radarr" = {
          hostPath = "${cfg.stateDir}/radarr";
          isReadOnly = false;
        };
        "/var/lib/readarr" = {
          hostPath = "${cfg.stateDir}/readarr";
          isReadOnly = false;
        };
        "/var/lib/sonarr" = {
          hostPath = "${cfg.stateDir}/sonarr";
          isReadOnly = false;
        };
      };

      config =
        { pkgs, ... }:
        {
          # Must match host GID so bind-mounted paths are writable
          users.groups.multimedia.gid = cfg.multimediaGid;

          # Pin UIDs to match state dir ownership on the host.
          # bazarr and readarr are not in nixpkgs ids.nix so their UIDs can diverge
          # across systems. prowlarr uses DynamicUser=yes upstream and requires an
          # explicit static user.
          users.users.bazarr.uid = cfg.bazarrUid;
          users.users.readarr.uid = cfg.readarrUid;
          users.users.qbittorrent.uid = cfg.qbittorrentUid;
          users.users.prowlarr = {
            uid = cfg.prowlarrUid;
            group = "prowlarr";
            isSystemUser = true;
          };
          users.groups.prowlarr = { };
          systemd.services.prowlarr.serviceConfig.DynamicUser = lib.mkForce false;

          # ProtonVPN WireGuard in an isolated network namespace so all qbittorrent
          # traffic is forced through the VPN and cannot leak via the container veth.
          networking.wireguard.interfaces.${vpnInterface} = {
            privateKeyFile = "/run/secrets/protonvpn.key";
            ips = [ cfg.protonvpn.ip ];
            peers = [
              {
                publicKey = cfg.protonvpn.publicKey;
                allowedIPs = [ "0.0.0.0/0" ];
                endpoint = cfg.protonvpn.endpoint;
              }
            ];
            interfaceNamespace = vpnNamespace;
            preSetup = ''ip netns add "${vpnNamespace}" 2>/dev/null || true'';
            postSetup = ''
              ip -n "${vpnNamespace}" link set up dev "lo"
              ip -n "${vpnNamespace}" route replace default dev "${vpnInterface}"
            '';
            preShutdown = ''ip -n "${vpnNamespace}" route del default dev "${vpnInterface}" 2>/dev/null || true'';
            postShutdown = ''ip netns del "${vpnNamespace}" 2>/dev/null || true'';
          };

          # DNS inside the VPN namespace resolves via ProtonVPN's resolver
          environment.etc."netns/${vpnNamespace}/resolv.conf".text = "nameserver ${cfg.protonvpn.gateway}";

          services = {
            bazarr = {
              enable = true;
              openFirewall = true;
              group = "multimedia";
              listenPort = cfg.ports.bazarr;
            };
            flaresolverr = {
              enable = true;
              openFirewall = true;
              port = cfg.ports.flaresolverr;
            };
            lidarr = {
              enable = true;
              openFirewall = true;
              group = "multimedia";
              settings.server.port = cfg.ports.lidarr;
            };
            prowlarr = {
              enable = true;
              openFirewall = true;
              settings.server.port = cfg.ports.prowlarr;
            };
            qbittorrent = {
              enable = true;
              openFirewall = true;
              group = "multimedia";
              webuiPort = cfg.ports.qbittorrent;
              # Disable built-in UPnP/NAT-PMP: ProtonVPN's gateway won't respond to
              # qbittorrent's own mapping requests through the tunnel — handled by
              # the protonvpn-port-forward service instead.
              # LocalHostAuth=false lets the port-forward service call the API from
              # within the VPN namespace without needing credentials.
              serverConfig = lib.recursiveUpdate {
                LegalNotice.Accepted = true;
                Preferences = {
                  Connection = {
                    UPnP = false;
                    NATPMPEnabled = false;
                  };
                  WebUI.LocalHostAuth = false;
                };
              } cfg.qbittorrent.serverConfig;
            };
            radarr = {
              enable = true;
              openFirewall = true;
              group = "multimedia";
              settings.server.port = cfg.ports.radarr;
            };
            readarr = {
              enable = true;
              openFirewall = true;
              group = "multimedia";
              settings.server.port = cfg.ports.readarr;
            };
            sonarr = {
              enable = true;
              openFirewall = true;
              group = "multimedia";
              settings.server.port = cfg.ports.sonarr;
            };
          };

          # qbittorrent runs inside the VPN network namespace; it cannot reach the
          # outside world except through the WireGuard tunnel.
          systemd.services.qbittorrent = {
            bindsTo = [ "wireguard-${vpnInterface}.service" ];
            requires = [
              "network-online.target"
              "wireguard-${vpnInterface}.service"
              "proxy-to-qbittorrent.service"
            ];
            serviceConfig.NetworkNamespacePath = "/var/run/netns/${vpnNamespace}";
          };

          # Socket proxy: bridges the qbittorrent web UI from the VPN namespace
          # (where it binds on 127.0.0.1) to the container's main namespace
          # (where Caddy can reach it at the container IP).
          systemd.services.proxy-to-qbittorrent = {
            description = "Proxy to qBittorrent in VPN network namespace";
            requires = [ "proxy-to-qbittorrent.socket" ];
            after = [
              "qbittorrent.service"
              "proxy-to-qbittorrent.socket"
            ];
            unitConfig.JoinsNamespaceOf = "qbittorrent.service";
            serviceConfig = {
              User = "qbittorrent";
              Group = "multimedia";
              ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:${toString cfg.ports.qbittorrent}";
              PrivateNetwork = "yes";
            };
          };

          systemd.sockets.proxy-to-qbittorrent = {
            description = "Socket for proxy to qBittorrent in VPN namespace";
            listenStreams = [ (toString cfg.ports.qbittorrent) ];
            wantedBy = [ "sockets.target" ];
          };

          # NAT-PMP port forwarding: asks ProtonVPN's gateway for a public port
          # mapping every 45 s and pushes that port into qbittorrent via its API.
          # Runs inside the VPN namespace (JoinsNamespaceOf) so natpmpc can reach
          # the ProtonVPN gateway and the API call hits qbittorrent directly.
          systemd.services.protonvpn-port-forward = {
            description = "NAT-PMP port forwarding through ProtonVPN for qBittorrent";
            bindsTo = [
              "wireguard-${vpnInterface}.service"
              "qbittorrent.service"
            ];
            after = [ "qbittorrent.service" ];
            wantedBy = [ "multi-user.target" ];
            unitConfig.JoinsNamespaceOf = "qbittorrent.service";
            serviceConfig = {
              User = "qbittorrent";
              Group = "multimedia";
              PrivateNetwork = "yes";
              Restart = "on-failure";
              RestartSec = "30s";
              ExecStart = pkgs.writeShellScript "protonvpn-port-forward" ''
                # Give qbittorrent's web server time to come up
                sleep 5
                while true; do
                  tcp_out=$(${pkgs.libnatpmp}/bin/natpmpc -a 1 0 tcp 60 -g ${cfg.protonvpn.gateway} 2>&1) || true
                  ${pkgs.libnatpmp}/bin/natpmpc -a 1 0 udp 60 -g ${cfg.protonvpn.gateway} >/dev/null 2>&1 || true

                  port=$(printf '%s\n' "$tcp_out" | grep "Mapped public port" | ${pkgs.gawk}/bin/awk '{print $4}')

                  if [ -n "$port" ]; then
                    echo "NAT-PMP mapped port $port — updating qBittorrent listen port"
                    ${pkgs.curl}/bin/curl -sf -X POST \
                      "http://127.0.0.1:${toString cfg.ports.qbittorrent}/api/v2/app/setPreferences" \
                      --data-urlencode "json={\"listen_port\": $port}" \
                      -o /dev/null \
                      || echo "Failed to update qBittorrent listen port (will retry)"
                  else
                    echo "NAT-PMP request failed:"
                    printf '%s\n' "$tcp_out"
                  fi

                  sleep 45
                done
              '';
            };
          };

          system.stateVersion = "26.05";
        };
    };
  };
}
