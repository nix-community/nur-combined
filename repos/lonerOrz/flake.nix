{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    rust-overlay,
    ...
  }: let
    systems = [
      "x86_64-linux"
      "i686-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "armv6l-linux"
      "armv7l-linux"
    ];

    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
  in {
    legacyPackages = forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            rust-overlay.overlays.default
            (import ./overlays/rustPlatform.nix)
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
        nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
    );
  };
}
