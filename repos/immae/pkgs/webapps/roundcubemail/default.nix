{ varDir ? "/var/lib/roundcubemail"
, roundcube_config ? "/etc/roundcube/config.php"
, stdenv, fetchurl }:
let
  defaultInstall = ''
    mkdir -p $out
    cp -R . $out/
    cd $out
    if [ -d skins -a -d skins/larry -a ! -d skins/elastic ]; then
      ln -s larry skins/elastic
    fi
    '';
  buildPlugin = { appName, version, url, sha256, installPhase ? defaultInstall }:
    stdenv.mkDerivation rec {
      name = "roundcube-${appName}-${version}";
      inherit version;
      phases = "unpackPhase installPhase";
      inherit installPhase;
      src = fetchurl { inherit url sha256; };
      passthru.pluginName = appName;
    };
  withPlugins = plugins: skins: package.overrideAttrs(old: {
    name = "${old.name}${if builtins.length skins > 0 then "-with-skins" else ""}${if builtins.length plugins > 0 then "-with-plugins" else ""}";
    installPhase = old.installPhase +
      builtins.concatStringsSep "\n" (
        map (value: "ln -s ${value} $out/plugins/${value.pluginName}") plugins
      ) +
      builtins.concatStringsSep "\n" (
        map (value: "ln -s ${value} $out/skins/${value.skinName}") skins
      );
    passthru = old.passthru // {
      inherit plugins skins;
      withPlugins = morePlugins: moreSkins: old.withPlugins (morePlugins ++ plugins) (morePlugins ++ skins);
    };
  });
  package = stdenv.mkDerivation rec {
    version = "1.4-rc1";
    name = "roundcubemail-${version}";
    src= fetchurl {
      url = "https://github.com/roundcube/roundcubemail/releases/download/${version}/${name}-complete.tar.gz";
      sha256 = "0p18wffwi2prh6vxhx1bc69qd1vwybggm8gvg3shahfdknxci9i4";
    };
    buildPhase = ''
      sed -i \
        -e "s|RCUBE_INSTALL_PATH . 'temp.*|'${varDir}/cache';|" \
        config/defaults.inc.php
      sed -i \
        -e "s|RCUBE_INSTALL_PATH . 'logs.*|'${varDir}/logs';|" \
        config/defaults.inc.php
    '';
    installPhase = ''
      cp -a . $out
      ln -s ${roundcube_config} $out/config/config.inc.php
    '';
    passthru = {
      plugins = [];
      skins = [];
      inherit withPlugins buildPlugin;
    };
  };
in package
