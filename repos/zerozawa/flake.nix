{
  description = "zerozawa's NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  nixConfig = {
    extra-substituters = [
      "https://zerozawa.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "zerozawa.cachix.org-1:9jPl+Xq6S4va32gPNJXTApDafDUwa5zjgFX65QfJ1CQ="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
      pkgsFor = system: import nixpkgs { inherit system; };
      legacyFor =
        system:
        import ./default.nix {
          pkgs = pkgsFor system;
        };
      # CI selection rules live in ci.nix; it is not part of the NUR exports.
      ciPackagesFor =
        system:
        import ./ci.nix {
          inherit lib;
          exports = legacyFor system;
        };
    in
    {
      legacyPackages = forAllSystems legacyFor;
      packages = forAllSystems (
        system:
        lib.filterAttrs (
          n: v:
          lib.elem system ((v.meta or { platforms = lib.platforms.none; }).platforms or lib.platforms.none)
        ) (lib.filterAttrs (_: v: lib.isDerivation v) self.legacyPackages.${system})
      );
      # CI build set: flattened list of buildable, cacheable exports.
      ciPackages = forAllSystems ciPackagesFor;
      # Same set keyed by derivation name, so CI can build each entry as a
      # flake installable.
      ciJobs = forAllSystems (
        system:
        builtins.listToAttrs (
          map (p: {
            name = p.name;
            value = p;
          }) (ciPackagesFor system)
        )
      );
    };
}
