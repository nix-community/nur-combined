{ ttrss_config ? "/etc/ttrss/config.php"
, varDir ? "/var/lib/ttrss"
, stdenv, mylibs }:
let
  withPlugins = plugins: package.overrideAttrs(old: rec {
    name = "${old.name}-with-plugins";
    installPhase = old.installPhase +
      builtins.concatStringsSep "\n" (
        map (value: "ln -s ${value} $out/plugins/${value.pluginName}") plugins
      );
    passthru = old.passthru // {
      inherit plugins;
      withPlugins = morePlugins: old.withPlugins (morePlugins ++ plugins);
    };
  });
  package = stdenv.mkDerivation (mylibs.fetchedGit ./tt-rss.json // rec {
    buildPhase = ''
      rm -rf lock feed-icons cache
      ln -sf ${varDir}/{lock,feed-icons,cache} .
      '';
      installPhase = ''
        cp -a . $out
        ln -s ${ttrss_config} $out/config.php
      '';
    passthru = {
      plugins = [];
      inherit withPlugins;
    };
  });
in package
