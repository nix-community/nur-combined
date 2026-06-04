{
  callPackage,
  buildGo126Module,
  lib,
  sources,
  go,
}:

let
  caddy = callPackage ./package.nix {
    inherit caddy;
    inherit buildGo126Module;
  };
  pluginSources = lib.filterAttrs (_n: v: (v.isCaddyPlugin or null) == "true") sources;
  plugins = lib.mapAttrsToList (
    _n: v: "${v.moduleName}@v0.0.0-${v.date}-${lib.substring 0 12 v.version}"
  ) pluginSources;
in
(caddy.withPlugins.override { inherit go; }) {
  inherit plugins;
  hash = "sha256-13aSdI21WSMQK1T1e4nRjOjYPcdx1ihLl1S0UUAxAe8=";
}
