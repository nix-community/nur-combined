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
            sing-server
            stalwart

          ])
        )
        ++ [
          (inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
          (inputs.nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
        ];

      identity.user = "elen";

      system = {
        # This headless machine uses to perform heavy task.
        # Running database and web services.
        stateVersion = "25.05";
      };
      boot = {
        supportedFilesystems = [ "tcp_bbr" ];
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

        kernelPackages = pkgs.linuxPackages_latest;
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
      systemd = {
        enableEmergencyMode = false;
        settings.Manager = {
          RebootWatchdogSec = "20s";
          RuntimeWatchdogSec = "30s";
        };
      };
      services = {
        yggdrasil.settings.AllowedPublicKeys = [
          "870b1f8c965df2b3220d9d6e4e8457f8f025f641873d00266adb3275d9025f14"
        ];
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
                listen = "[::]:8776";
                remote = "[fdcc::3]:8776";
              }
            ];
          };
        };

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
