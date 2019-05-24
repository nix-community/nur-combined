{ mantis_config ? "/etc/mantisbt/config_inc.php", stdenv, fetchurl }:
let
  withPlugins = plugins: package.overrideAttrs(old: {
    name = "${old.name}-with-plugins";
    installPhase = old.installPhase + (
      builtins.concatStringsSep "\n" (
        map (value: if builtins.hasAttr "selector" value then
            "ln -sf ${value}/${value.selector} $out/plugins/"
          else
            "ln -sf ${value} $out/plugins/${value.pluginName}"
        ) plugins
      ));
    passthru = old.passthru // {
      inherit plugins;
      withPlugins = morePlugins: old.withPlugins (morePlugins ++ plugins);
    };
  });
  package = stdenv.mkDerivation rec {
    name = "mantisbt-${version}";
    version = "2.21.0";
    src = fetchurl {
      url = "https://downloads.sourceforge.net/project/mantisbt/mantis-stable/${version}/${name}.tar.gz";
      sha256 = "13lx569dp1gibq5daqp7dj6gsqic85rrix1s7xkp60gwpzk8wiw5";
    };
    patches = [
      ./bug_report.php.diff
      ./bug_report_page.php.diff
      ./bugnote_add.php.diff
      ./bugnote_add_inc.php.diff
    ];
    installPhase = ''
    cp -a . $out
    ln -s ${mantis_config} $out/config/config_inc.php
    '';

    passthru = {
      plugins = [];
      inherit withPlugins;
    };
  };
in package
