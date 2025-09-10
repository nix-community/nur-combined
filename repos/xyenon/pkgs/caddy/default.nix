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
      _n: v:
      let
        goDate =
          if hasInfix "+" v.date || hasInfix "-" v.date then
            let
              splitedDate = splitString (if hasInfix "+" v.date then "+" else "-") v.date;
              datetime = elemAt splitedDate 0;
              timezone = elemAt splitedDate 1;
              date = substring 0 8 datetime;
              time = substring 8 14 datetime;
              calculateUtc =
                timeStr: tzStr:
                let
                  time = toIntBase10 timeStr;
                  tz = (toIntBase10 tzStr) * 100;
                in
                if hasInfix "+" v.date then time - tz else time + tz;
              utcTime = calculateUtc time timezone;
              realDateTime =
                if utcTime < 0 then
                  {
                    date = date - 1;
                    time = utcTime + 240000;
                  }
                else if utcTime > 240000 then
                  {
                    date = date + 1;
                    time = utcTime - 240000;
                  }
                else
                  {
                    inherit date;
                    time = utcTime;
                  };
            in
            "${fixedWidthNumber 8 realDateTime.date}${fixedWidthNumber 6 realDateTime.time}"
          else
            v.date;
      in
      "${v.moduleName}@v0.0.0-${goDate}-${substring 0 12 v.version}"
    ) pluginSources;
in
(caddy.withPlugins.override { inherit go; }) {
  inherit plugins;
  hash = "sha256-TIQ4T0ak4DEvN9DybNZgtdI3jwniTq9/x3uE9DPVN/c=";
}
