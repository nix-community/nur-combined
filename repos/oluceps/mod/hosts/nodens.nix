{
  self,
  inputs,
  ...
}:
{
  os.nodens.module =
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
            vaultix
            shared-modules
            users
            sudo
            empheral-root
            base
            plugIn
            vxlan-mesh
            yggdrasil
            earlyoom
            chrony
            # sing-server
            xray

          ])
        )
        ++ [
          (inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
          (inputs.nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
        ];

      identity.user = "elen";
      xray.configFile = config.vaultix.secrets.xray.path;

      zramSwap = {
        enable = false;
        swapDevices = 1;
        memoryPercent = 50;
        algorithm = "lz4";
      };
      system = {
        # This headless machine uses to perform heavy task.
        # Running database and web services.
        stateVersion = "25.05";
      };
      boot = {
        supportedFilesystems = [ ];
        kernelModules = [ "tcp_bbr" ];
        loader = {
          efi = {
            canTouchEfiVariables = true;
            efiSysMountPoint = "/efi";
          };
          systemd-boot.enable = true;
          timeout = 3;
        };

        kernelPackages = pkgs.linuxPackages_latest;
        kernelParams = [
          "audit=0"
          "net.ifnames=0"
          "console=ttyS0"
          "earlyprintk=ttyS0"
          "rootdelay=300"
          "19200n8"

          "zswap.enabled=1"
          "zswap.compressor=zstd"
          "zswap.zpool=zsmalloc"
          "zswap.max_pool_percent=25"
          "zswap.shrinker_enabled=1"
        ];
        initrd = {
          compressor = "zstd";
          compressorArgs = [
            "-19"
            "-T0"
          ];
        };

      };
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
        	}
        }
        loki.write "default" {
        	endpoint {
        		url = "http://[fdcc::3]:3030/loki/api/v1/push"
        	}
        	external_labels = {}
        }
      '';

      systemd = {
        enableEmergencyMode = false;
        settings.Manager = {
          RebootWatchdogSec = "20s";
          RuntimeWatchdogSec = "30s";
        };
      };
      services = {
        alloy.enable = true;
        # dnsproxy.settings = lib.mkForce {
        #   bootstrap = [
        #     "1.1.1.1"
        #     "8.8.8.8"
        #   ];
        #   listen-addrs = [ "0.0.0.0" ];
        #   listen-ports = [ 53 ];
        #   upstream-mode = "load_balance";
        #   upstream = [
        #     "1.1.1.1"
        #     "8.8.8.8"
        #     "https://dns.google/dns-query"
        #   ];
        # };
        metrics.enable = true;
      };

      nixpkgs = {
        hostPlatform = "aarch64-linux";
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
