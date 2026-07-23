{
  self,
  inputs,
  ...
}:
{
  os.azasos.module =
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
            base
            vxlan-mesh
            yggdrasil
            chrony
            prometheus
            xray
            ntfy
            subs
          ])
          ++ [ (inputs.nixpkgs + "/nixos/modules/profiles/qemu-guest.nix") ]
        );

      identity.user = "elen";
      system = {
        stateVersion = "25.11";
      };

      xray.configFile = config.vaultix.secrets.xray.path;
      boot = {
        kernelPackages = pkgs.linuxPackages_latest;
        kernelParams = [
          "audit=0"
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

      services = {
        metrics.enable = true;
      };

      nixpkgs = {
        hostPlatform = "x86_64-linux";
        overlays = [ self.overlays.default ];
        config = {
          allowUnsupportedSystem = true;
          allowUnfree = true;
        };
      };
    };
}
