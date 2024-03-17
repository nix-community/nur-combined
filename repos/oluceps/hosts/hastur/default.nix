{ withSystem, self, inputs, ... }:
{
  flake.nixosConfigurations.hastur = withSystem "x86_64-linux" (_ctx@{ config, inputs', ... }:
    let inherit (self) lib; in lib.nixosSystem
      {
        specialArgs = {
          inherit lib self inputs inputs';
          inherit (config) packages;
          inherit (lib) data;
          user = "riro";
        };
        modules = lib.sharedModules ++ [
          {
            nixpkgs = {
              hostPlatform = "x86_64-linux";
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
                  "fenix"
                  "berberman"
                  "nuenv"
                  "android-nixpkgs"
                  "agenix-rekey"
                  "misskey"
                  "nixpkgs-wayland"
                ]);
            };
          }
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

          ../sysctl.nix

          inputs.home-manager.nixosModules.default
          ../../home

          ../../users.nix

          inputs.misskey.nixosModules.default
          ./misskey.nix

          ./vaultwarden.nix
          inputs.niri.nixosModules.niri
          ./prometheus.nix

        ]
          ++
          [
            inputs.aagl.nixosModules.default
            inputs.disko.nixosModules.default
            # inputs.j-link.nixosModule
          ];
      });
}
