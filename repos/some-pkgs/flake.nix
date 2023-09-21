{
  description = "some-pkgs: sci-comp packages that have no place in nixpkgs";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";

  outputs = { self, nixpkgs }:
    let
      lib = import ./lib/extend-lib.nix nixpkgs.lib;
      systems = builtins.filter (name: builtins.hasAttr name nixpkgs.legacyPackages) [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: lib.genAttrs systems (system: f system);

      defaultPlatforms = [ "x86_64-linux" ];

      supportsPlatform = system: name: package:
        let s = builtins.elem system (package.meta.platforms or defaultPlatforms); in s;

      reservedName = name: builtins.elem name [
        "lib"
        "python"
        "python3"
      ];

      filterUnsupported = system: packages:
        let
          filters = [
            (name: _: ! reservedName name)
            (name: attr: attr ? type && attr.type == "derivation")
            (supportsPlatform system)
          ];
          f = name: package: builtins.all (f: f name package) filters;
        in
        lib.filterAttrs f packages;

      overlay = import ./overlay.nix;

      pkgs = forAllSystems (system: import nixpkgs {
        inherit system;
        overlays = [ overlay ];
      });

      pkgsUnfree = forAllSystems (system: import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          cudaSupport = true;
          cudaCapabilities = [ "8.6" ];
        };
        overlays = [ overlay ];
      });

      newAttrs = forAllSystems (system: pkgs.${system}.some-pkgs // pkgs.${system}.some-pkgs.some-pkgs-py);
      supportedPkgs = lib.mapAttrs filterUnsupported newAttrs;

      outputs = {
        inherit overlay lib;

        packages = supportedPkgs;
        legacyPackages = newAttrs // (forAllSystems (system: {
          pkgs = pkgs.${system};
          pkgsUnfree = pkgsUnfree.${system};
        }));
      };
    in
    outputs;
}
