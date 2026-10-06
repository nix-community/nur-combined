{
  callPackage,
  buildGoModule,
  lib,
  sources,
  go,
}:

let
  caddy = callPackage ./package.nix { inherit buildGoModule; };
  pluginSources = lib.filterAttrs (_n: v: (v.isCaddyPlugin or null) == "true") sources;
  plugins = lib.mapAttrsToList (
    _n: v: "${v.moduleName}@v0.0.0-${v.date}-${lib.substring 0 12 v.version}"
  ) pluginSources;
in
(caddy.withPlugins.override { inherit go; }) {
  inherit plugins;
  hash = "sha256-bwr5XdfxpMC1HgKLKPgetYGfCKYlUEjLkCgdv8fvTEA=";
}
