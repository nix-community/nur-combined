{
  description = "Rafael Ieda's Nix User Repository";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      # Unfree is allowed so that this repository's own unfree packages
      # (the Jagex Launcher) build from `packages`; nothing else of nixpkgs
      # is exposed. The overlay and the modules use the consumer's nixpkgs,
      # and its own unfree setting, instead.
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      isReserved =
        n:
        lib.elem n [
          "lib"
          "homeModules"
          "modules"
          "nixosModules"
          "overlays"
        ];
    in
    {
      # Everything default.nix returns, as NUR sees it
      legacyPackages = forAllSystems (system: import ./default.nix { pkgs = pkgsFor system; });

      # The packages, each only on the platforms it supports
      packages = forAllSystems (
        system:
        lib.filterAttrs (
          n: p: !isReserved n && lib.isDerivation p && lib.meta.availableOn { inherit system; } p
        ) self.legacyPackages.${system}
      );

      # Adds the packages to the consumer's nixpkgs
      overlays.default = import ./overlay.nix;

      nixosModules = import ./modules;

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
