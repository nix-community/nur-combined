{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      legacyPackages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              rust-overlay.overlays.default
            ];
          };

          legacyPkgs = import ./default.nix {
            inherit pkgs;
          };
        in
        legacyPkgs
      );

      packages = forAllSystems (
        system:
        let
          lib = nixpkgs.lib;
        in
        lib.filterAttrs (
          _: v: lib.isDerivation v && lib.meta.availableOn system v
        ) self.legacyPackages.${system}
      );
    };
}
