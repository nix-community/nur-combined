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
              ciPackages = (import ./ci.nix { pkgs = pkgsFor system; }).packages;
            };
          }
        );
        # Flake default pins every registered recipe to this repository's nixpkgs
        # lock, matching legacyPackages, direct flake outputs, and CI/cache drvPaths.
        # Keep `unpinned` as an explicit consumer-nixpkgs variant for callers who
        # prefer the NUR overlay behavior. Kernel package sets still use consumer pkgs.
        overlays = import ./overlays // {
          default =
            final: _prev:
            import ./overlays/flake.nix {
              pinned = inputs.self.legacyPackages.${final.stdenv.hostPlatform.system};
              pkgs = final;
            };
          unpinned = (import ./overlays).default;
        };
        nixosModules.default = { ... }: { };
      };
    };
}
