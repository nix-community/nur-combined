{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs =
    { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      legacyPackages = forAllSystems (
        system:
        import ./default.nix {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        }
      );
      packages = forAllSystems (
        system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
      );
      overlays = import ./overlays;

      # NixOS modules
      nixosModules = {
        vintagestory = import ./modules/vintagestory.nix ./pkgs/vintagestory;

        # Default imports all modules
        default =
          { ... }:
          {
            imports = [
              self.nixosModules.vintagestory
            ];
          };
      };
    };
}
