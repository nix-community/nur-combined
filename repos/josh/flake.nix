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
      internal-inputs = builtins.mapAttrs (
        _name: node: builtins.getFlake (builtins.flakeRefToString node.locked)
      ) (builtins.fromJSON (builtins.readFile ./internal/flake.lock)).nodes;

      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      inherit (nixpkgs) lib;
      eachSystem = lib.genAttrs systems;
      addAttrsetPrefix = prefix: lib.attrsets.concatMapAttrs (n: v: { "${prefix}${n}" = v; });

      mkPackages =
        pkgs:
        let
          nurpkgs = import ./default.nix { inherit pkgs; };
        in
        lib.attrsets.filterAttrs (_: pkg: pkg.meta.available) nurpkgs;

      mkChecks =
        name: pkgs:
        let
          buildCheckPkg =
            pkg: pkgs.runCommand "${pkg.name}-${name}-build" { nativeBuildInputs = [ pkg ]; } "touch $out";
        in
        lib.attrsets.concatMapAttrs (
          pkgName: pkg:
          if (builtins.hasAttr "tests" pkg) then
            (
              {
                "${pkgName}-${name}-build" = buildCheckPkg pkg;
              }
              // (addAttrsetPrefix "${pkgName}-${name}-tests-" pkg.tests)
            )
          else
            { "${pkgName}-${name}-build" = buildCheckPkg pkg; }
        ) (mkPackages pkgs);

      treefmt-nix = eachSystem (import ./internal/treefmt.nix);
    in
    {
      overlays.default = final: _prev: {
        nur.repos.josh = import ./default.nix { pkgs = final; };
      };

      packages = eachSystem (system: mkPackages nixpkgs.legacyPackages.${system});

      formatter = eachSystem (system: treefmt-nix.${system}.wrapper);
      checks = eachSystem (
        system:
        {
          formatting = treefmt-nix.${system}.check self;
        }
        // (mkChecks "stable" internal-inputs.nixpkgs-stable.legacyPackages.${system})
        // (mkChecks "unstable" internal-inputs.nixpkgs-unstable.legacyPackages.${system})
      );
    };
}
