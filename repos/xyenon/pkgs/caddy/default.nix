{
  callPackage,
  buildGo124Module,
  lib,
  sources,
  go_1_24,
}:

let
  caddy = callPackage ./package.nix {
    inherit caddy;
    buildGoModule = buildGo124Module;
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
      _n: v:
      let
        goDate =
          if hasInfix "+" v.date then
            let
              splitedDate = splitString "+" v.date;
              date = elemAt splitedDate 0;
              timezone = elemAt splitedDate 1;
            in
            toString ((toIntBase10 date) - ((toIntBase10 timezone) * 100))
          else if hasInfix "-" v.date then
            let
              splitedDate = splitString "-" v.date;
              date = elemAt splitedDate 0;
              timezone = elemAt splitedDate 1;
            in
            toString ((toIntBase10 date) + ((toIntBase10 timezone) * 100))
          else
            v.date;
      in
      "${v.moduleName}@v0.0.0-${goDate}-${substring 0 12 v.version}"
    ) pluginSources;
in
(caddy.withPlugins.override { go = go_1_24; }) {
  inherit plugins;
  hash = "sha256-V8wJIQzeT1EweDbEx3pSfGHV5yXghZRAeDk2gfNFizc=";
}
