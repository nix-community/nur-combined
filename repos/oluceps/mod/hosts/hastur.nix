{
  self,
  inputs,
  ...
}:
{
  os.hastur.module =
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
            earlyoom
            incus
            vaultix
            shared-modules
            users
            sudo
            empheral-root-full
            gui
            oo7-session
            base
            dev
            plugIn
            garage
            vxlan-mesh
            yggdrasil
            earlyoom
            # dae
            # honk
            # limes
            secureboot
            home
            chrony
            prometheus
            # xray
            june
            vocat
            artex
            magpie
            # ipex
            # scx
          ])
        )
        ++ [
          (inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
          inputs.owly.nixosModules.default
        ];

      identity.user = "riro";
      services.oo7-session = {
        defaultKeyring = "Default_Keyring";
        requiredKeyrings = [ "login" ];
      };
      incus.bridgeAddr = "fdcc:1::1/64";
      # xray.configFile = config.vaultix.secrets.xray-cli.path;

      environment.systemPackages = [
        pkgs.nvtopPackages.intel
        pkgs.chafa
        pkgs.mcp-grafana
        # pkgs.texlive.combined.scheme-full
      ];

      environment.etc."alloy/config.alloy".text = ''
        discovery.relabel "journal" {
        	targets = []
        	rule {
        		source_labels = ["__journal__systemd_unit"]
        		target_label  = "unit"
        	}
        }
        loki.source.journal "sshd" {
        	forward_to    = [loki.write.default.receiver]
        	relabel_rules = discovery.relabel.journal.rules
        	matches       = "_SYSTEMD_UNIT=sshd.service"
        	max_age       = "12h0m0s"
        	labels        = {
        		host = "${config.networking.hostName}",
        		job  = "systemd-journal",
        	}
        }
        loki.source.journal "sudo" {
        	forward_to    = [loki.write.default.receiver]
        	relabel_rules = discovery.relabel.journal.rules
        	matches       = "_COMM=sudo"
        	max_age       = "12h0m0s"
        	labels        = {
        		host = "${config.networking.hostName}",
        		job  = "systemd-journal",
        		comm = "sudo",
        	}
        }
        loki.write "default" {
        	endpoint {
            url = "http://127.0.0.1:13030/loki/api/v1/push"
        	}
        	external_labels = {}
        }
      '';

      system = {
        # This headless machine uses to perform heavy task.
        # Running database and web services.

        stateVersion = "24.11";
      };
      boot = {
        # binfmt.emulatedSystems = [ "aarch64-linux" ];
        zswap = {
          enable = true;
          compressor = "zstd";
          zpool = "zsmalloc";
          maxPoolPercent = 20;
          shrinkerEnabled = true;
        };
        kernel.sysctl = {
          "vm.vfs_cache_pressure" = lib.mkForce 200;
        };
        lanzaboote.measuredBoot = {
          enable = true;
          pcrs = [
            0
            4
            7
          ];
          autoCryptenroll = {
            enable = true;
            device = config.boot.initrd.luks.devices."cryptroot".device;
          };
        };
        loader.efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/efi";
        };

        initrd = {
          availableKernelModules = [
            "nvme"
            "xhci_pci"
            "usb_storage"
            "usbhid"
            "sd_mod"
          ];
        };
        kernelModules = [
          "kvm-amd"
          "wacom"
        ];
        extraModulePackages = with config.boot.kernelPackages; [
          v4l2loopback
        ];
        extraModprobeConfig = ''
          options v4l2loopback devices=1 video_nr=1 card_label="OBS Virtual Camera" exclusive_caps=1
        '';
        kernelPackages =
          # (inputs.nix-cachyos-kernel.mkFixedVersionKernelWith pkgs).linuxPackages-cachyos-latest-lto;
          # inputs'.nix-cachyos-kernel.linuxPackages-cachyos-latest-lto-zen4;
          # let
          #   helpers = pkgs.callPackage "${inputs.nix-cachyos-kernel.outPath}/helpers.nix" { };

          #   rawKernel = pkgs.cachyosKernels.linux-cachyos-bore-lto.override {
          #     pname = "linux-cachyos-custom-kernel";
          #     processorOpt = "zen4";
          #     extraMakeFlags = [ "KCFLAGS=-march=znver5" ];
          #   };
          # in
          # helpers.kernelModuleLLVMOverride (pkgs.linuxKernel.packagesFor rawKernel);
          pkgs.linuxPackages_testing;
        blacklistedKernelModules = [ "hid_nintendo" ];
        kernelParams = [
          "amd_pstate=active"
          "amd_iommu=on"
          "random.trust_cpu=off"
          "zswap.enabled=1"
          "zswap.compressor=zstd"
          "zswap.zpool=zsmalloc"
          "zswap.max_pool_percent=25"
          "zswap.shrinker_enabled=1"
        ];

      };
      systemd = {
        enableEmergencyMode = false;
        # random encrypted swap
        sleep.settings.Sleep.AllowHibernation = "no";
        settings.Manager = {
          RebootWatchdogSec = "20s";
          RuntimeWatchdogSec = "30s";
        };
      };
      realm.observability.endpoints.syncthing.port = 8384;
      services = {
        # Did you read the comment?
        blueman.enable = true;
        syncthing = {
          enable = true;
          openDefaultPorts = true;
          inherit (config.identity) user;
          guiAddress = "127.0.0.1:8384";
        };
        smartd.notifications.systembus-notify.enable = true;
        metrics.enable = true;
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
            timerConfig.onCalendar = "*:0/10";
          }
          {
            name = "var";
            source = "/var";
            keep = "7day";
            timerConfig.onCalendar = "daily";
          }
        ];
        sing-box.enable = true;
        gvfs.enable = false;
        alloy.enable = true;

        # AirDrop over awdl0 on the RTL8852CE. The card is in Owly's quirks
        # table but not marked tested, so allow_untested is required. Shared
        # mode needs the AP on channel 6, 44 or 149.
        owly = {
          enable = true;
          settings = {
            station = "wlan0";
            allow_untested = true;
          };
        };

        xserver.videoDrivers = [ "modesetting" ];
      };
      hardware = {
        graphics = {
          enable = true;
          extraPackages = with pkgs; [
            vpl-gpu-rt
            intel-media-driver
          ];
        };
        bluetooth.enable = true; # enables support for Bluetooth
        bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
        cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
      virtualisation.oci-containers.containers."cliproxyapi" = {
        image = "docker.io/eceasy/cli-proxy-api:v8.0.21";
        volumes = [
          "${
            pkgs.writeText "cliproxyapi-config" # yaml
              ''
                # Server host/interface to bind to. Default is empty ("") to bind all interfaces (IPv4 + IPv6).
                host: ""

                # Server port
                port: 8317

                # TLS settings for HTTPS.
                tls:
                  enable: false
                  cert: ""
                  key: ""

                # Plugin settings
                plugins:
                  enabled: true
                  dir: "/CLIProxyAPI/plugins"

                # Management API settings
                remote-management:
                  allow-remote: true
                  secret-key: "admin123"
                  disable-control-panel: false
                  panel-github-repository: "https://github.com/router-for-me/Cli-Proxy-API-Management-Center"
              ''
          }:/CLIProxyAPI/config.yaml:rw"
          "/var/lib/cliproxyapi/auth-dir:/root/.cli-proxy-api:rw"
          "/var/lib/cliproxyapi/plugins:/CLIProxyAPI/plugins:rw"
        ];
        log-driver = "journald";
        extraOptions = [
          "--network=host"
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
