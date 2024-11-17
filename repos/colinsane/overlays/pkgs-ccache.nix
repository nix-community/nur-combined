# `pkgsCCcache.foo`: builds `foo`, using the `ccache` compiler so that incremental builds are cheaper.
# requires `programs.ccache.enable = true`  (see: </hosts/modules/roles/build-machine.nix>)
#
# common operations:
# - `nix-ccache --show-stats`
# - `du -h /var/cache/ccache`
#
# example:
# - `nix-build --builders "" -A pkgsCross.aarch64-multiplatform.pkgsCCache.mesa`  (it's stackable)
#
# cache efficacy is fairly disappointing. a cross-compiled kernel might build in 35min the first time then 34min the second time (thanks to the cache).
(final: prev:
let
  mkCCacheStdenv = pkgs: let
    # the clunky `buildPackages.ccacheWrapper.override { inherit (stdenv) cc; }`
    # is to overcome some cross-compilation issues, where the `ccache.links` wrapper
    # script isn't spliced, and so gets built for the host architecture.
    ccacheWrapper' = pkgs.buildPackages.ccacheWrapper.override {
        # inherit (pkgs) stdenv;
      inherit (pkgs.stdenv) cc;
      extraConfig = ''
        # export CCACHE_COMPRESS=1
        export CCACHE_DIR=/var/cache/ccache
        export CCACHE_UMASK=007
      '';
    };
  in pkgs.overrideCC pkgs.stdenv ccacheWrapper';

  tryOverride = pkg: attrName: attrValue: let
    pkg' = pkg.override { "${attrName}" = attrValue; };
  in if ((pkg.override or {}).__functionArgs or {})."${attrName}" or true then
    pkg
  else
    pkg';

  replaceCcFlags = pkgs: pkg: pkg.overrideAttrs (base: {
    makeFlags = builtins.map (final.lib.replaceStrings [ "${pkgs.stdenv.cc}" ] [ "${(mkCCacheStdenv pkgs).cc}" ]) base.makeFlags;
  });

  tryEnableCCache = pkg: let
    pkgFixStdenv = tryOverride pkg "stdenv" (mkCCacheStdenv final);
    pkgFixBuildPackages = tryOverride pkgFixStdenv "buildPackages" (final.buildPackages // { stdenv = mkCCacheStdenv final.buildPackages; });
    pkgFixFlags = replaceCcFlags final pkgFixBuildPackages;
    pkgFixFlagsBuild = replaceCcFlags final.buildPackages pkgFixFlags;
  in
    pkgFixFlagsBuild;

in
{
  pkgsCCache = final.lib.mapAttrs (_pname: tryEnableCCache) final;

  # this should work, but fails due to infinite recursion?
  # pkgsCCache = final.extend (self: super: {
  #   stdenv = super.overrideCC firstPkgs.stdenv firstPkgs.buildPackages.ccacheWrapper;
  #   # or:
  #   # callPackage = path: overrides: super.callPackage path ({ stdenv = self.ccacheStdenv; } // overrides);
  # });
})
