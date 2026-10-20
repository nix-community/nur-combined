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
          }
        );
        overlays = import ./overlays;
        nixosModules.default = { ... }: { };
      };
    };
}
