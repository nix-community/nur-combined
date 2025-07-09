{
  lib,
  flake-parts-lib,
  ...
}:
let
  ciPackages = flake-parts-lib.mkTransposedPerSystemModule {
    name = "ciPackages";
    option = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.package;
      default = { };
    };
    file = ./ci.nix;
  };
in
{
  imports = [
    ciPackages
  ];

  perSystem =
    {
      self',
      pkgs,
      system,
      ...
    }:
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
    in
    {
      ciPackages = lib.filterAttrs (
        name: p: isBuildable p && isCacheable p && isSupported p
      ) self'.packages;
    };
}
