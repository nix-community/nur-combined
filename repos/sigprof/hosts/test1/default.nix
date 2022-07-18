{
  self,
  inputs,
  ...
}: let
  system = "x86_64-linux";
  unstable = inputs.nixos-unstable.legacyPackages.${system};
in
  inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      self.nixosModules.default

      ({pkgs, ...}: {
        system.stateVersion = "22.05";
        networking.hostName = "test1";
        fileSystems."/".device = "/dev/sda1";
        boot.loader.grub.device = "/dev/sda";

        sigprof.hardware.gpu.driver.nvidia.legacy_340.enable = true;

        services.printing.enable = true;
        sigprof.hardware.printers.driver.hplip.enable = true;
        sigprof.hardware.printers.driver.hplip.enablePlugin = true;

        hardware.sane.enable = true;
        sigprof.hardware.sane.backend.epkowa.enable = true;

        sigprof.i18n.ru_RU.enable = true;

        environment.systemPackages = [
          pkgs.tor-browser-bundle-bin
          self.packages.${system}.virt-manager

          unstable.tdesktop
          unstable.vial
        ];

        fonts.fonts = [
          self.packages.${system}.cosevka
        ];
      })
    ];
  }
