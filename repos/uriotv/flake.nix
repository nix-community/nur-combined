{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        { system, ... }:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          legacyPackages = import ./default.nix { inherit pkgs; };
          packages = pkgs.lib.filterAttrs (_: v: pkgs.lib.isDerivation v) (
            import ./default.nix { inherit pkgs; }
          );
        };

      flake = {
        overlays = import ./overlays;
        nixosModules = {
          vintagestory = import ./modules/vintagestory.nix ./pkgs/vintagestory;
          default =
            { ... }:
            {
              imports = [ inputs.self.nixosModules.vintagestory ];
            };
        };
      };
    };
}
