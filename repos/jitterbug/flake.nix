{
  description = "JuniorIsAJitterbug's nur-packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      legacyPackages = forAllSystems (
        system:
        import ./default.nix {
          pkgs = import nixpkgs {
            inherit system;

            config = {
              allowUnfree = true;
            };
          };
        }
      );

      packages = forAllSystems (
        system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
      );

      checks = forAllSystems (system: self.packages.${system});
      nixosModules = import ./modules;

      devShells = forAllSystems (
        system:
        import ./shell.nix {
          pkgs = import nixpkgs { inherit system; };
        }
      );
    };

  nixConfig = {
    extra-experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
