{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nixpak = {
      url = "github:nixpak/nixpak/3b061c82f9ccb99973154ffced2391535da7b66b";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpak,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      eachSystem = f: lib.genAttrs systems (system: f system);

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            (import ./overlays { inherit nixpak; })
          ];
        };

      legacyPackages = eachSystem (
        system:
        import ./default.nix {
          pkgs = mkPkgs system;
        }
      );

      packages = lib.mapAttrs (
        system: attrs:
        lib.filterAttrs (_: v: lib.isDerivation v && lib.meta.availableOn { inherit system; } v) attrs
      ) legacyPackages;
    in
    {
      inherit legacyPackages packages;

      formatter = eachSystem (system: (mkPkgs system).callPackage ./formatter.nix { });
    };
}
