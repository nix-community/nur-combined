{ self, inputs, ... }: {

  flake =
    let lib = inputs.nixpkgs.lib.extend self.overlays.lib; in
    {
      nixosConfigurations = {
        hastur = inputs.nixpkgs.lib.nixosSystem
          {
            pkgs = import inputs.nixpkgs {
              system = "x86_64-linux";
              config = {
                # contentAddressedByDefault = true;
                allowUnfree = true;
                allowBroken = false;
                segger-jlink.acceptLicense = true;
                allowUnsupportedSystem = true;
                permittedInsecurePackages = lib.mkForce [ "electron-25.9.0" ];
              };
              overlays = (import ../../overlays.nix inputs)
                ++
                (lib.genOverlays [
                  "self"
                  # "clansty"
                  "fenix"
                  "berberman"
                  "EHfive"
                  "nuenv"
                  "android-nixpkgs"
                  "agenix-rekey"
                  "misskey"
                  "nixpkgs-wayland"
                ]);
            };
            specialArgs = lib.base // {
              inherit lib;
              user = "riro";
            };
            modules = [
              ./hardware.nix
              ./network.nix
              ./rekey.nix
              ./spec.nix
              ./matrix.nix

              ../persist.nix
              ../secureboot.nix
              ../../packages.nix
              ../../services/misc.nix
              ../../misc.nix
              ../../sysvars.nix
              ../../age.nix

              ../../boot.nix

              inputs.home-manager.nixosModules.default
              ../../home

              ../../users.nix

              inputs.misskey.nixosModules.default
              ./misskey.nix

              ./vaultwarden.nix
              inputs.niri.nixosModules.niri
              ./prometheus.nix

            ] ++ lib.sharedModules
            ++
            [
              inputs.aagl.nixosModules.default
              inputs.disko.nixosModules.default
              # inputs.j-link.nixosModule
            ];
          };
      };
    };
}
