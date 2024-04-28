{
  description = "Personal NUR repository by mloeper";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs?rev=2726f127c15a4cc9810843b96cad73c7eb39e443";
  inputs.nix-alien = {
    url = "github:thiagokokada/nix-alien";
    inputs.nixpkgs.follows = "nixpkgs";
    # TODO(mloeper): idk why the following does not work as it is patched, see: https://github.com/NixOS/nix/pull/8819
    #inputs.nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-alien, ... }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      legacyPackages = forAllSystems (system: import ./default.nix {
        pkgs = import nixpkgs {
          inherit system;
        };
        nix-alien = nix-alien.packages.${system}.nix-alien;
      });
      packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
      nixosModules = import ./modules;
    };
}
