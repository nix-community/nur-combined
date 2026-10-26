{
  self,
  inputs,
  ...
}:
{
  os.abhoth.module =
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
            # xray
            stalwart
            rustypaste
            wgmesh

            security-toolkit
            shellbox
          ])
        )
        ++ [
          (inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
          (inputs.nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
        ];

      identity.user = "elen";
      # xray.configFile = config.vaultix.secrets.xray.path;
      wgmesh.configFile = "/var/lib/wgmesh/config.json";

      swapDevices = [
        {
          device = "/var/swapfile";
          size = 2048;
          priority = 0;
        }
      ];

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
        zswap = {
          enable = true;
          compressor = "lz4";
          zpool = "zsmalloc";
          maxPoolPercent = 25;
          shrinkerEnabled = true;
        };
        supportedFilesystems = [ ];
        kernelModules = [
          "tcp_bbr"
        ];
        extraModulePackages = [ ];
        loader = {
          timeout = 3;
          grub.enable = false;
          limine = {
            enable = true;
            efiSupport = false;
            biosSupport = true;
            biosDevice = "/dev/vda";
            maxGenerations = 3;
          };
        };

        kernelPackages = pkgs.linuxPackages_testing;
        kernelParams = [
          "audit=0"
          "net.ifnames=0"
          "console=ttyS0"
          "earlyprintk=ttyS0"
          "rootdelay=300"
          "19200n8"
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

      # ----- into sept vm
      systemd.sockets.sept-ssh = {
        description = "Babel SSH forwarding socket";
        wantedBy = [ "sockets.target" ];

        listenStreams = [ "[::]:52020" ];

        socketConfig = {
          Accept = false;
          BindIPv6Only = "both";
          FreeBind = true;
        };
      };

      systemd.services.sept-ssh = {
        description = "Forward SSH through Babel";

        serviceConfig = {
          Type = "notify";
          # systemd-socket-proxyd expects the IPv6 host without brackets.
          ExecStart = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd fdcc::3:2223";

          DynamicUser = true;
          NoNewPrivileges = true;
          ProtectSystem = "strict";
          ProtectHome = true;
        };
      };
      networking.firewall.allowedTCPPorts = [ 52020 ];

      #----------

      systemd.sockets.radicle-proxy = {
        description = "Radicle forwarding socket";
        wantedBy = [ "sockets.target" ];
        listenStreams = [ "[::]:8776" ];
        socketConfig = {
          BindIPv6Only = "both";
          FreeBind = true;
        };
      };

      systemd.services.radicle-proxy = {
        description = "Forward Radicle connections";
        requires = [ "radicle-proxy.socket" ];
        serviceConfig = {
          ExecStart = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd fdcc::3:8776";
          DynamicUser = true;
          NoNewPrivileges = true;
          ProtectSystem = "strict";
          ProtectHome = true;
        };
      };

      services = {
        alloy.enable = true;
        yggdrasil.settings.AllowedPublicKeys = [
          "870b1f8c965df2b3220d9d6e4e8457f8f025f641873d00266adb3275d9025f14"
        ];
        hysteria.instances.main = {
          enable = true;
          configFile = config.vaultix.secrets.hy.path;
          serve = true;
          openFirewall = 4500;
        };
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
}
