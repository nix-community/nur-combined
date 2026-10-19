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
          kernel = import ./pkgs/linux-cachyos-bore-x86_64-v3/pinned.nix { inherit system; };
          kernelExports = pkgs.lib.optionalAttrs (system == "x86_64-linux") {
            linux-cachyos-bore-x86_64-v3 = kernel.kernel;
          };
          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          legacyPackages = import ./default.nix { inherit pkgs; } // kernelExports
            // pkgs.lib.optionalAttrs (system == "x86_64-linux") {
              linuxPackages-cachyos-bore-x86_64-v3 = kernel.kernelPackages;
            };
          packages = pkgs.lib.filterAttrs (_: v: pkgs.lib.isDerivation v) (
            import ./default.nix { inherit pkgs; } // kernelExports
          );
          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.nix-update
            ];
          };
        };

      flake = {
        overlays = import ./overlays;
        nixosModules = rec {
          cachyos = import ./modules/cachyos-kernel.nix {
            defaultKernelPackages = (import ./pkgs/linux-cachyos-bore-x86_64-v3/pinned.nix { }).kernelPackages;
          };
          default = cachyos;
        };
      };
    };
}
