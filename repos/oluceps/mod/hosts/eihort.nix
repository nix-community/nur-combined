{
  self,
  inputs,
  ...
}:
{
  os.eihort.module =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      realm.workloads.pocket-id = {
        user = config.services.pocket-id.user;
        group = config.services.pocket-id.group;
        isolation = {
          runtimePaths = [ "/run/pocket-id" ];
          allowUnixSockets = [ "/run/postgresql" ];
          hosts."box.nyaw.xyz" = "127.0.0.1";
        };
        ingressGroups = [ config.services.pocket-id.group ];
        ingress = {
          http = {
            port = 11411;
            backend = {
              kind = "unix";
              path = "/run/pocket-id/http.sock";
            };
            service = "pocket-id";
            allow.identities = config.realm.caddy.allowedIDs.pocket-id;
          };
          metrics = {
            port = 19464;
            backend = {
              kind = "private-tcp";
              port = 9464;
            };
            service = "pocket-id-metrics";
            allow.identities = [ config.realm.workloads.observability.spiffeID ];
          };
        };
        http.internet = true;
        egress = {
          smtp = {
            service = "smtp-submission";
            localPort = 465;
          };
        };
      };
      realm.workloads.observability.egress.pocket-id = {
        service = "pocket-id-metrics";
      };
      realm.observability.endpoints.pocket-id.socket = "/run/realm/observability/egress/pocket-id.sock";
      systemd.services.pocket-id = {
        requires = [ "postgresql.target" ];
        after = [ "postgresql.target" ];
        serviceConfig = {
          PrivateNetwork = lib.mkForce true;
          RuntimeDirectory = "pocket-id";
        };
      };
      imports =
        with self.modules;
        (
          (with generic; [
            data
            fn
          ])
          ++ (with nixos; [
            overlay
            identity
            openssh
            fail2ban
            earlyoom
            incus
            vaultix
            shared-modules
            users
            sudo
            empheral-root-full
            base
            dev
            plugIn
            vxlan-mesh
            yggdrasil
            scrutiny
            secureboot
            earlyoom
            # dae
            chrony
            postgresql
            atuin
            misskey
            meilisearch
            vaultwarden
            mautrix-telegram
            synapse
            calibre
            # xray
            immich
            # radicle
            seaweedfs
            prometheus
            grafana

            loki
            alloy
            suricata
            jellyfin
            samba
            ncps
            forgejo
            sept
            virt
            # clickhouse

            # pxe
          ])
        )
        ++ [
          (inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
          inputs.nuanmonito.nixosModules.nuanmonito
          inputs.online-exporter.nixosModules.default
        ];

      identity.user = "elen";
      incus.bridgeAddr = "fdcc:3::1/64";
      realm.observability.endpoints.cloudflared.port = 20241;
      realm.observability.endpoints.tg-online.port = 8087;
      # xray.configFile = config.vaultix.secrets.xray-cli.path;

      hardware.facter = {
        reportPath = ../eihort_facter.json;
        detected.dhcp.enable = false;
      };
      system = {
        # This headless machine uses to perform heavy task.
        # Running database and web services.

        stateVersion = "24.11";
      };
      boot = {
        supportedFilesystems = [
          "zfs"
          "ntfs"
        ];
        zfs = {
          devNodes = "/dev/disk/by-id";
          extraPools = [ "pool0" ];
          forceImportRoot = false;
        };

        loader = {
          efi = {
            canTouchEfiVariables = true;
            efiSysMountPoint = "/efi";
          };
          timeout = 3;
        };
        blacklistedKernelModules = [
          "intel_oc_wdt"
          "iTCO_wdt"
          "iTCO_vendor_support"
        ];
        kernelModules = [ "ipmi_watchdog" ];
        extraModprobeConfig = ''
          options ipmi_watchdog action=reset
        '';

        kernelParams = [
          # "audit=0"
          # "net.ifnames=0"
          "ia32_emulation=0"
          "zswap.enabled=1"
          "zswap.compressor=lz4"
          "zswap.zpool=zsmalloc"
          "zswap.accept_threshold_percent=70"
          "zswap.shrinker_enabled=1"
        ];

        initrd = {
          compressor = "zstd";
          compressorArgs = [
            "-19"
            "-T0"
          ];
          systemd.enable = true;

          availableKernelModules = [
            "usb_storage"
            "mpt3sas"
          ];
        };

        kernelPackages = pkgs.linuxPackages;
      };

      zramSwap = {
        enable = false;
        swapDevices = 1;
        memoryPercent = 40;
        algorithm = "zstd";
      };
      systemd = {
        enableEmergencyMode = false;
        settings.Manager = {
          RebootWatchdogSec = "20s";
          RuntimeWatchdogSec = "30s";
        };
      };
      systemd.sockets.sept-proxy = {
        description = "Sept forwarding socket";
        wantedBy = [ "sockets.target" ];
        listenStreams = [ "[::]:1905" ];
        socketConfig = {
          BindIPv6Only = "both";
          FreeBind = true;
        };
      };

      systemd.services.sept-proxy = {
        description = "Forward connections to Sept";
        requires = [ "sept-proxy.socket" ];
        serviceConfig = (import ../../lib/proxy-hardening.nix) // {
          ExecStart = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd 10.255.0.1:1095";
          DynamicUser = true;
          NoNewPrivileges = true;
          CapabilityBoundingSet = "";
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          ProtectProc = "ptraceable";
          ProcSubset = "pid";
          RestrictSUIDSGID = true;
          RestrictNamespaces = true;
          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
          ];
          SystemCallArchitectures = "native";
        };
      };

      services = {
        zfs = {
          autoScrub.enable = true;
          optimization = {
            enable = true;
            arcMinGiB = 8;
            aggressiveL2ARC = true;
            disablePrefetch = true;
          };
        };
        rsyncd = {
          enable = true;
          socketActivated = true;
        };
        cloudflared = {
          enable = true;
          edgeDnsOverHttps = true;
          environmentFile = config.vaultix.secrets.cfd.path;
        };
        nuanmonito = {
          enable = true;
          package = inputs.nuanmonito.packages.${pkgs.stdenv.hostPlatform.system}.nuanmonito;
          environmentFile = config.vaultix.secrets.nuan.path;
        };
        target = {
          enable = true;
          # ugly
          config = builtins.fromJSON (builtins.readFile ../target_cfg.json);
        };
        # openiscsi = {
        #   enable = true;
        #   discoverPortal = "ip:3260";
        #   name = "iqn.2005-10.org.nixos.ctl:ntfs-games";
        # };
        rqbit = {
          enable = true;
          location = "/pool0/storage/Downloads";
        };
        # bpftune.enable = true;
        sing-box.enable = true;
        metrics.enable = true;
        online-exporter.instances.zro = {
          environmentFile = config.vaultix.secrets.monitou.path;
        };

        # ranet-discover = {
        #   enable = true;
        #   registry = "/var/lib/garden/registry.json";
        #   key = config.vaultix.secrets.garden_key.path;
        #   interface = "eno1";
        # };
        pocket-id = {
          enable = true;
          settings = {
            APP_URL = "https://oidc.nyaw.xyz";
            UNIX_SOCKET = "/run/pocket-id/http.sock";
            UNIX_SOCKET_MODE = "0660";
            DB_CONNECTION_STRING = "postgresql://pocket-id@localhost/pocketid?host=/run/postgresql&sslmode=disable";
            TRUST_PROXY = true;
            OTEL_METRICS_EXPORTER = "prometheus";
            OTEL_EXPORTER_PROMETHEUS_HOST = "127.0.0.1";
            OTEL_EXPORTER_PROMETHEUS_PORT = 9464;
          };
          environmentFile = config.vaultix.secrets.pocketid.path;
        };

        # online-keeper.instances.sec = {
        #   sessionFile = config.vaultix.secrets.tg-session.path;
        #   environmentFile = config.vaultix.secrets.tg-env.path;
        # };

        btrfs.autoScrub = {
          enable = true;
          interval = "weekly";
          fileSystems = [
            "/persist"
          ];
        };

        snapy.instances = [
          {
            name = "persist";
            source = "/persist";
            keep = "2day";
            timerConfig.onCalendar = "hourly";
          }
          {
            name = "var";
            source = "/var";
            keep = "3day";
            timerConfig.onCalendar = "daily";
          }
        ];

      };

      nixpkgs = {
        hostPlatform = "x86_64-linux";
        overlays = [
          self.overlays.default
        ];
        config = {
          allowUnsupportedSystem = true;
          allowUnfree = true;
          permittedInsecurePackages = [
            "olm-3.2.16"
          ];
        };
      };
    };
}
