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
            scrutiny
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
            garage
            vxlan-mesh
            yggdrasil
            scrutiny
            secureboot
            earlyoom
            dae
            chrony
            postgresql
            atuin
            misskey
            meilisearch
            vaultwarden
            mautrix-telegram
            synapse
            calibre
            immich
            radicle
            seaweedfs
            prometheus
            grafana

            loki
            alloy
            zeek
            jellyfin
            samba
            ncps
            forgejo
            sept
            zeek
          ])
        )
        ++ [
          (inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
          inputs.nuanmonito.nixosModules.nuanmonito
          inputs.online-exporter.nixosModules.default
        ];

      identity.user = "elen";
      incus.bridgeAddr = "fdcc:3::1/64";

      system = {
        # This headless machine uses to perform heavy task.
        # Running database and web services.

        stateVersion = "24.11";
      };
      boot = {
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
          "zswap.compressor=zstd"
          "zswap.zpool=zsmalloc"
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

        kernelPackages = pkgs.linuxPackages_latest;
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
      services = {
        rsyncd = {
          enable = true;
          socketActivated = true;
        };
        cloudflared = {
          enable = true;
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
          location = "/three/storage/Downloads";
        };
        # bpftune.enable = true;
        sing-box.enable = true;
        metrics.enable = true;
        online-exporter.instances.zro = {
          # sessionFile = config.vaultix.secrets.tgexp.path;
          environment = [
            "TG_API_HASH=d524b414d21f4d37f08684c1df41ac9c"
            "TG_API_ID=611335"
            "MONITOR_USER_IDS=454999736,6280888824,594807459"
          ];
        };

        # ranet-discover = {
        #   enable = true;
        #   registry = "/var/lib/garden/registry.json";
        #   key = config.vaultix.secrets.garden_key.path;
        #   interface = "eno1";
        # };
        realm = {
          enable = true;
          settings = {
            log.level = "warn";
            network = {
              no_tcp = false;
              use_udp = true;
            };
            endpoints = [
              {
                listen = "[::]:1905";
                remote = "10.255.0.1:1095";
              }
            ];
          };
        };
        pocket-id = {
          enable = true;
          settings = {
            APP_URL = "https://oidc.nyaw.xyz";
            TRUST_PROXY = true;
            OTEL_METRICS_EXPORTER = "prometheus";
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
            "/three"
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
