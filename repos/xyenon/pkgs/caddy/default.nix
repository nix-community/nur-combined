{
  callPackage,
  buildGo125Module,
  lib,
  sources,
  go,
}:

let
  caddy = callPackage ./package.nix {
    inherit caddy;
    inherit buildGo125Module;
  };
  pluginSources = lib.filterAttrs (_n: v: (v.isCaddyPlugin or null) == "true") sources;
  plugins = lib.mapAttrsToList (
    _n: v: "${v.moduleName}@v0.0.0-${v.date}-${lib.substring 0 12 v.version}"
  ) pluginSources;
in
(caddy.withPlugins.override { inherit go; }) {
  inherit plugins;
  hash = "sha256-fE9cJVW95cpLZIDk9coxfzPrdATFPbLXz6PNF9Hc37c=";
}
