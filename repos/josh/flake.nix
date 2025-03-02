{
  description = "@josh's Nix User Repository";

  nixConfig = {
    extra-substituters = [
      "https://josh.cachix.org"
    ];
    extra-trusted-public-keys = [
      "josh.cachix.org-1:qc8IeYlP361V9CSsSVugxn3o3ZQ6w/9dqoORjm0cbXk="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      inherit (nixpkgs) lib;
      eachSystem = lib.genAttrs systems;
      eachPkgs = f: eachSystem (system: f nixpkgs.legacyPackages.${system});

      treefmt-nix = eachPkgs (import ./internal/treefmt.nix);
    in
    {
      overlays.default = final: _prev: {
        nur.repos.josh = import ./default.nix { pkgs = final; };
      };

      packages = eachPkgs (
        pkgs:
        let
          isAvailable = _: pkg: pkg.meta.available;
          nurpkgs = import ./default.nix { inherit pkgs; };
          availablePkgs = lib.attrsets.filterAttrs isAvailable (
            builtins.removeAttrs nurpkgs [ "nodePackages" ]
          );
        in
        availablePkgs
      );

      formatter = eachSystem (system: treefmt-nix.${system}.wrapper);
      checks = eachSystem (
        system:
        let
          addAttrsetPrefix = prefix: lib.attrsets.concatMapAttrs (n: v: { "${prefix}${n}" = v; });
          localTests = lib.attrsets.concatMapAttrs (
            pkgName: pkg:
            if (builtins.hasAttr "tests" pkg) then
              ({ "${pkgName}-build" = pkg; } // (addAttrsetPrefix "${pkgName}-tests-" pkg.tests))
            else
              { "${pkgName}-build" = pkg; }
          ) self.packages.${system};
        in
        {
          formatting = treefmt-nix.${system}.check self;
        }
        // localTests
      );
    };
}
