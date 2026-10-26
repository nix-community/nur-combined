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
            earlyoom
            vaultix
            shared-modules
            users
            empheral-root
            # base
            nix
            cut
            bash
            env
            pki
            security
            sysctl

            #--base
            vxlan-mesh
            yggdrasil
            # xray
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
        # xray.configFile = config.vaultix.secrets.xray.path;

        system = {
          # This headless machine uses to perform heavy task.
          # Running database and web services.
          stateVersion = "26.11";
        };

        users.users.elen.shell = lib.mkForce pkgs.bash;
        services.journald.settings.Journal = {
          SystemMaxUse = lib.mkForce "0.1G";
        };

        environment.etc."alloy/config.alloy".text = ''
          livedebugging {
            enabled = false
          }
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
          loki.source.journal "autopeer" {
            forward_to    = [loki.write.default.receiver]
            relabel_rules = discovery.relabel.journal.rules
            matches       = "_SYSTEMD_UNIT=autopeer.service"
            max_age       = "12h0m0s"
            labels        = {
              host = "${config.networking.hostName}",
              job  = "systemd-journal",
            }
          }
          loki.write "default" {
            endpoint {
              url = "http://127.0.0.1:13030/loki/api/v1/push"
              batch_size = "64KiB"
              batch_wait = "1s"
            }
            external_labels = {}
          }
        '';
        swapDevices = [
          {
            device = "/var/swapfile";
            size = 512;
            priority = 0;
          }
        ];
        zramSwap.enable = false;

        boot = {
          zswap = {
            enable = true;
            compressor = "lz4";
            zpool = "zsmalloc";
            maxPoolPercent = 20;
            shrinkerEnabled = true;
          };
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

          kernelPackages = pkgs.linuxPackages_testing;
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

          # 452 MB RAM: Alloy causes memory pressure; Envoy logs stay local.
          alloy.enable = lib.mkForce false;

          metrics.enable = true;
          qemuGuest.enable = false;
          hysteria.instances.main = {
            enable = true;
            serve = true;
            configFile = config.vaultix.secrets.hy.path;
            openFirewall = 4500;
          };
        };
        documentation = {
          enable = false;
          nixos.enable = false;
          man.enable = false;
          info.enable = false;
          doc.enable = false;
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
