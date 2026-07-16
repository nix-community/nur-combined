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
            base
            dev
            plugIn
            garage
            vxlan-mesh
            yggdrasil
            earlyoom
            dae
            # limes
            secureboot
            home
            chrony
            prometheus
            # xray
            june
            # scx
          ])
        )
        ++ [
          (inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
        ];

      identity.user = "riro";
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
        		url = "http://[fdcc::3]:3030/loki/api/v1/push"
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
        extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
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
          pkgs.linuxPackages_latest;
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
      zramSwap = {
        enable = false;
        swapDevices = 1;
        memoryPercent = 80;
        algorithm = "zstd";
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
      services = {
        # Did you read the comment?
        blueman.enable = true;
        syncthing = {
          enable = true;
          openDefaultPorts = true;
          inherit (config.identity) user;
          guiAddress = "[::]:8384";
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
