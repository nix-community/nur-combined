{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
          apps = pkgs.lib.optionalAttrs (system == "x86_64-linux") {
            build-and-cache-kernel = {
              type = "app";
              program = pkgs.lib.getExe (pkgs.writeShellApplication {
                name = "build-and-cache-kernel";
                runtimeInputs = [ pkgs.nix pkgs.cachix pkgs.curl pkgs.jq pkgs.coreutils pkgs.gnugrep ];
                text = ''
                  export KERNEL_FLAKE=${inputs.self.outPath}
                  ${builtins.readFile ./scripts/build-and-cache-kernel.sh}
                '';
              });
            };
          };
          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.nix-update
              pkgs.sops
              pkgs.age
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
          kernel-publisher-options = import ./modules/kernel-publisher-secrets.nix;
          kernel-publisher = {
            imports = [
              inputs.sops-nix.nixosModules.sops
              kernel-publisher-options
            ];
          };
        };
      };
    };
}
