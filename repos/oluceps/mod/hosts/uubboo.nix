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
            dae
          ])
        )
        ++ [
          (inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
        ];

      identity.user = "elen";

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
        sing-box.enable = true;
      };

      nixpkgs = {
        hostPlatform = "x86_64-linux";
        overlays = [
          self.overlays.default
        ];
      };
    };
}
