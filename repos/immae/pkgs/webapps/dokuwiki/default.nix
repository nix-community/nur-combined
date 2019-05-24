{ varDir ? "/var/lib/dokuwiki", preload ? "", lib, stdenv, mylibs, writeText }:
let
  preloadFile = plugins: let preloads = [preload]
      ++ builtins.concatMap (p: lib.optional (lib.hasAttr "preload" p) (p.preload p)) plugins;
    in writeText "preload.php" (''
      <?php
      '' + builtins.concatStringsSep "\n" preloads
    );
  withPlugins = plugins: package.overrideAttrs(old: {
    name = "${old.name}-with-plugins";
    installPhase = old.installPhase + (
      builtins.concatStringsSep "\n" (
        map (value: "ln -sf ${value} $out/lib/plugins/${value.pluginName}") plugins
        )
      );
    installPreloadPhase = ''
      cp ${preloadFile plugins} $out/inc/preload.php
      '';
    passthru = old.passthru // {
      inherit plugins;
      withPlugins = morePlugins: old.withPlugins (morePlugins ++ plugins);
    };
  });
  package = stdenv.mkDerivation (mylibs.fetchedGithub ./dokuwiki.json // rec {
    phases = "unpackPhase buildPhase installPhase installPreloadPhase fixupPhase";
    buildPhase = ''
      mv conf conf.dist
      mv data data.dist
    '';
    installPhase = ''
      cp -a . $out
      ln -sf ${varDir}/{conf,data} $out/
      ln -sf ${varDir}/conf/.htaccess $out/
    '';
    installPreloadPhase = ''
      cp ${preloadFile []} $out/inc/preload.php
      '';
    passthru = {
      plugins = [];
      inherit withPlugins varDir;
    };
  });
in package
