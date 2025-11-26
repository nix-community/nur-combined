{ inputs, ... }: {
  imports = [ inputs.flake-parts.flakeModules.partitions ];

  perSystem = { self', pkgs, ... }: let
    inherit (pkgs) lib;

    cachable = x:
      lib.isDerivation x
      && !(x.meta.broken or false)
      && !(x.preferLocalBuild or false)
      && (x.allowSubstitutes or true);

    packages = lib.filter cachable (lib.attrValues self'.legacyPackages);
  in {
    checks.build = pkgs.linkFarmFromDrvs "ci-build-all" packages;
  };

  partitions."dev" = {};
  partitionedAttrs.checks = "dev";
}
