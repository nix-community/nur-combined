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

        services.printing.enable = true;
        sigprof.hardware.printers.driver.hplip.enable = true;
        sigprof.hardware.printers.driver.hplip.enablePlugin = true;

        hardware.sane.enable = true;
        sigprof.hardware.sane.backend.epkowa.enable = true;

        sigprof.i18n.ru_RU.enable = true;

        environment.systemPackages = [
          pkgs.kicad-small
          pkgs.tor-browser-bundle-bin
          self.packages.${system}.virt-manager

          # Temporary until the Home Manager config is ported
          self.packages.${system}.firefox-langpack-ru
          self.packages.${system}.thunderbird-langpack-ru

          unstable.tdesktop
          unstable.vial
        ];

        fonts.packages = [
          self.packages.${system}.cosevka
        ];
      })
    ];
  }
