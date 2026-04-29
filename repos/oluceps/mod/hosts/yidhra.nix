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
            chrony
            # sing-server
            xray
            rustypaste
            subs
            ntfy
          ])
        )
        ++ [
          (inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
          (inputs.nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
        ];

      identity.user = "elen";
      xray.configFile = config.vaultix.secrets.xray.path;

      system = {
        # This headless machine uses to perform heavy task.
        # Running database and web services.
        stateVersion = "25.11";
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
        metrics.enable = true;
        qemuGuest.enable = true;

        coturn = {
          enable = true;
          # static-auth-secret-file = config.vaultix.secrets.wg.path;
          no-auth = true;
          realm = config.networking.fqdn;
        };

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
