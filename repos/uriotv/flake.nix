{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      # The pinned nixpkgs no longer supports Intel macOS.
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      pkgsFor =
        system:
        import inputs.nixpkgs {
          inherit system;
          # Local/CI builds are permitted; redistribution is a separate decision.
          config.allowUnfree = true;
        };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      inherit systems;
      perSystem =
        { system, ... }:
        let
          pkgs = pkgsFor system;
          ci = import ./ci.nix { inherit pkgs; };
        in
        {
          legacyPackages = import ./default.nix { inherit pkgs; };
          packages = pkgs.lib.filterAttrs (
            _: p: pkgs.lib.meta.availableOn pkgs.stdenv.hostPlatform p
          ) ci.packages;
          checks = ci.buildPackages;
          devShells.default = pkgs.mkShell {
            packages = [ pkgs.nix-update ];
          };
        };
      flake = {
        ci = inputs.nixpkgs.lib.genAttrs systems (
          system:
          (import ./ci.nix { pkgs = pkgsFor system; })
          // {
            policyTests = import ./tests/package-policy.nix { lib = inputs.nixpkgs.lib; };
            overlayPinTests = import ./tests/overlay-pin.nix {
              pkgs = pkgsFor system;
              overlay = inputs.self.overlays.default;
              pinned = inputs.self.legacyPackages.${system};
            };
          }
        );
        # Flake overlay: everything as in ./overlays, but the CachyOS kernels come from
        # this flake's own nixpkgs (flake.lock), i.e. the exact derivations CI builds
        # and publishes. The consumer's nixpkgs therefore cannot change the kernel
        # hash; only linuxPackagesFor (out-of-tree modules) uses the consumer's pkgs.
        # Attribute names are static and the platform is read lazily, so NixOS
        # evaluation of boot.kernelPackages does not recurse through final.stdenv.
        overlays = import ./overlays // {
          default =
            final: prev:
            let
              pinned = inputs.self.legacyPackages.${final.stdenv.hostPlatform.system};
              kernels = {
                inherit (pinned) linux-cachyos-latest-x86_64-v3 linux-cachyos-bore-x86_64-v3;
              };
            in
            (import ./overlays).default final prev
            // kernels
            // import ./lib/cachyos/package-sets.nix {
              pkgs = final;
              inherit kernels;
            };
        };
        nixosModules.default = { ... }: { };
      };
    };
}
