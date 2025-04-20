{
  lib,
  sources,
  caddy,
}:

let
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
if lib.hasAttr "withPlugins" caddy then
  caddy.withPlugins {
    inherit plugins;
    hash = "sha256-Ys6efpXd7fRm4g62Lus55+SJz6hIa52kbeldPeExOgE=";
  }
else
  caddy.overrideAttrs (
    _finalAttrs: prevAttrs: {
      meta = prevAttrs.meta // {
        broken = true;
      };
    }
  )
