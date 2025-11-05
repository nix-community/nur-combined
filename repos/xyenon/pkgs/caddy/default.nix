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
  pluginRepos = [
    "WeidiDeng/caddy-cloudflare-ip"
    "caddy-dns/cloudflare"
    "mholt/caddy-l4"
    "mholt/caddy-webdav"
  ];
  pluginSources = lib.filterAttrs (n: _v: lib.elem n pluginRepos) sources;
  plugins =
    with lib;
    assert (length (attrNames pluginSources) == length pluginRepos);
    mapAttrsToList (
      _n: v: "${v.moduleName}@v0.0.0-${v.date}-${substring 0 12 v.version}"
    ) pluginSources;
in
(caddy.withPlugins.override { inherit go; }) {
  inherit plugins;
  hash = "sha256-Q7n2kcfZp4a4LjKniuJu962NF4m5ljqoGJj5AicPAH0=";
}
