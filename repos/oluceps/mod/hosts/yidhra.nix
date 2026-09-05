{
  self,
  inputs,
  ...
}:
{
  os.yidhra.module =
    {
      pkgs,
      config,
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
            # fail2ban # Disabled to save ~140MB space (Python3)
            earlyoom
            vaultix
            shared-modules
            users
            empheral-root
            # base
            cut
            fish
            bash
            nix
            env
            pki
            security
            sysctl

            #--base
            vxlan-mesh
            yggdrasil
            chrony
            xray
            perlless
            space-opt
          ])
        )
        ++ [
          (inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
          (inputs.nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
        ];

      config = {
        identity.user = "elen";
        xray.configFile = config.vaultix.secrets.xray.path;

        system = {
          # This headless machine uses to perform heavy task.
          # Running database and web services.
          stateVersion = "26.11";
        };

        # environment.etc."alloy/config.alloy".text = ''
        #   discovery.relabel "journal" {
        #   	targets = []
        #   	rule {
        #   		source_labels = ["__journal__systemd_unit"]
        #   		target_label  = "unit"
        #   	}
        #   }
        #   loki.source.journal "sshd" {
        #   	forward_to    = [loki.write.default.receiver]
        #   	relabel_rules = discovery.relabel.journal.rules
        #   	matches       = "_SYSTEMD_UNIT=sshd.service"
        #   	max_age       = "12h0m0s"
        #   	labels        = {
        #   		host = "${config.networking.hostName}",
        #   		job  = "systemd-journal",
        #   	}
        #   }
        #   loki.source.journal "sudo" {
        #   	forward_to    = [loki.write.default.receiver]
        #   	relabel_rules = discovery.relabel.journal.rules
        #   	matches       = "_COMM=sudo"
        #   	max_age       = "12h0m0s"
        #   	labels        = {
        #   		host = "${config.networking.hostName}",
        #   		job  = "systemd-journal",
        #   	}
        #   }
        #   loki.write "default" {
        #   	endpoint {
        #   		url = "http://[fdcc::3]:3030/loki/api/v1/push"
        #   	}
        #   	external_labels = {}
        #   }
        # '';
        boot = {
          # supportedFilesystems = [ "tcp_bbr" ]; # removed typo
          loader = {
            timeout = 10;
            # grub = {
            #   enable = true;
            #   # efiSupport = true;
            #   # biosSupport = true;
            #   # biosDevice = "/dev/sda";
            #   device = "/dev/sda";
            # };
            limine = {
              enable = true;
              efiSupport = false;
              biosSupport = true;
              biosDevice = "/dev/sda";
            };
          };

          kernelPackages = pkgs.linuxPackages_latest;
          kernelModules = [ "tcp_bbr" ];
          kernelParams = [
            "audit=0"
            "net.ifnames=0"
            # "console=ttyS0"
            # "earlyprintk=ttyS0"
            "rootdelay=300"
            "19200n8"
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
          settings.Manager = {
            RebootWatchdogSec = "20s";
            RuntimeWatchdogSec = "30s";
          };
        };
        services = {
          metrics.enable = true;
          qemuGuest.enable = true;
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
    };
}
