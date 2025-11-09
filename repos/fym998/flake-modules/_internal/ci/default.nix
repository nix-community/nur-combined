{
  config,
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (lib)
    filterAttrs
    mapAttrs
    mkOption
    types
    ;
  inherit (flake-parts-lib)
    mkSubmoduleOptions
    mkPerSystemOption
    ;
in
{
  options = {
    flake = mkSubmoduleOptions {
      ciPackages = mkOption {
        type =
          let
            T = types.lazyAttrsOf (
              types.oneOf [
                types.package
                T
              ]
            );
          in
          T;
        default = { };
        description = ''
          An attribute set of per system an attribute set packages to be built by CI.
        '';
      };
    };

    perSystem = mkPerSystemOption (
      {
        self',
        ...
      }:
      {
        _file = ./default.nix;
        options = {
          ciPackages = mkOption {
            type = types.lazyAttrsOf types.package;
            default = self'.packages;
            description = ''
              An attribute set of packages to be built by CI.
            '';
          };
        };
      }
    );
  };

  config = {
    flake.ciPackages = mapAttrs (
      system: ciPackages:
      let
        isBuildable =
          p:
          let
            licenseFromMeta = p.meta.license or [ ];
            licenseList = if builtins.isList licenseFromMeta then licenseFromMeta else [ licenseFromMeta ];
          in
          !(p.meta.broken or false) && builtins.all (license: license.free or true) licenseList;
        isCacheable = p: !(p.preferLocalBuild or false);
        isSupported = p: lib.elem system (p.meta.platforms or [ ]);

        # from https://github.com/drupol/pkgs-by-name-for-flake-parts/blob/main/flake-module.nix
        flattenPkgs =
          separator: path: value:
          if lib.isDerivation value then
            {
              ${lib.concatStringsSep separator path} = value;
            }
          else if lib.isAttrs value then
            lib.concatMapAttrs (name: flattenPkgs separator (path ++ [ name ])) value
          else
            # Ignore the functions which makeScope returns
            { };
      in
      filterAttrs (_name: p: isBuildable p && isCacheable p && isSupported p) (
        flattenPkgs "." [ ] ciPackages
      )
    ) (mapAttrs (_system: perSystem: perSystem.ciPackages) config.allSystems);

    perSystem =
      { pkgs, ... }:
      {
        legacyPackages._ci = lib.packagesFromDirectoryRecursive {
          inherit (pkgs) callPackage;
          directory = ./tools;
        };
      };
  };
}
