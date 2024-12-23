{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable/";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@attrs:
    let
      username = "haruka";
      mac-hostname = "kayiu-m1mac";
    in {
      homeConfigurations.${username} =
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."aarch64-linux";
          modules = [
            (import ./configs/home.nix { inherit username; })
            {
              targets.genericLinux.enable = true;
              home.packages = with nixpkgs.legacyPackages."aarch64-linux"; [
                librewolf
                vscodium
                qbittorrent
                telegram-desktop
                imagemagick
              ];
            }
          ];
        };

      darwinConfigurations.${mac-hostname} = attrs.nix-darwin.lib.darwinSystem {
        modules = [
          home-manager.darwinModules.home-manager
          (import ./configs/darwin.nix {
            inherit mac-hostname;
            inherit username;
          })
        ];
      };
    };
}
