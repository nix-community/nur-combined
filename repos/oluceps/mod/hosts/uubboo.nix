{
  self,
  inputs,
  ...
}:
{
  os.uubboo.module =
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
            vaultix
            shared-modules
            users
            sudo
            empheral-root
            base
            vxlan-mesh
            yggdrasil
            chrony
            # dae
            prometheus
          ])
        )
        ++ [
          (inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
        ];

      identity.user = "elen";

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

      system = {
        stateVersion = "26.05";
      };
      boot = {
        loader = {
          limine = {
            enable = true;
            efiSupport = true;
            biosSupport = true;
            biosDevice = "/dev/sda";
          };
        };

        kernelPackages = pkgs.linuxPackages_latest;
        kernelParams = [
          "audit=0"
          "net.ifnames=0"
        ];
        initrd = {
          compressor = "zstd";
          compressorArgs = [
            "-19"
            "-T0"
          ];
          systemd.enable = true;
        };

      };
      systemd = {
        enableEmergencyMode = false;
      };
      services = {
        metrics.enable = true;
        btrfs.autoScrub = {
          enable = true;
          interval = "weekly";
          fileSystems = [
            "/persist"
          ];
        };
        # sing-box.enable = true;
        alloy.enable = true;
        # hysteria.instances.main = {
        #   enable = true;
        #   configFile = "/home/elen/hy.yml";
        # };
      };
      # systemd.services.hysteria-main.serviceConfig = {
      #   DynamicUser = lib.mkForce false;
      #   User = "hysteria";
      #   Group = "hysteria";
      # };
      # users = {
      #   groups.hysteria = { };

      #   users = {
      #     hysteria = {
      #       isSystemUser = true;
      #       group = "hysteria";
      #     };

      #   };
      # };

      nixpkgs = {
        hostPlatform = "x86_64-linux";
        overlays = [
          self.overlays.default
        ];
      };
    };
}
