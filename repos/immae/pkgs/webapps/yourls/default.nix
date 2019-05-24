{ yourls_config ? "/etc/yourls/config.php", mylibs, stdenv }:
let
  withPlugins = plugins: package.overrideAttrs(old: {
    name = "${old.name}-with-plugins";
    installPhase = old.installPhase +
      builtins.concatStringsSep "\n" (
        map (value: "ln -s ${value} $out/user/plugins/${value.pluginName}") plugins
      );
    passthru = old.passthru // {
      inherit plugins;
      withPlugins = morePlugins: old.withPlugins (morePlugins ++ plugins);
    };
  });
  package = stdenv.mkDerivation (mylibs.fetchedGithub ./yourls.json // rec {
    installPhase = ''
      mkdir -p $out
      cp -a */ *.php $out/
      cp sample-robots.txt $out/robots.txt
      ln -sf ${yourls_config} $out/includes/config.php
    '';
    passthru = {
      plugins = [];
      inherit withPlugins;
    };
  });
in package
