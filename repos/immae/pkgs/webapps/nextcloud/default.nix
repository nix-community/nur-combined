{ varDir ? "/var/lib/nextcloud", otherConfig ? {}, lib, stdenv, fetchurl }:
let
  buildApp = { appName, version, url, sha256, otherConfig ? {}, installPhase ? "mkdir -p $out && cp -R . $out/" }:
    stdenv.mkDerivation rec {
      name = "nextcloud-app-${appName}-${version}";
      inherit version;
      phases = "unpackPhase installPhase";
      inherit installPhase;
      src = fetchurl { inherit url sha256; };
      passthru = {
        inherit appName otherConfig;
      };
    };
  withApps = apps: package.overrideAttrs(old: {
    name = "${old.name}-with-apps";

    installPhase = old.installPhase + (
      builtins.concatStringsSep "\n" (
        map (value: "ln -sf ${value} $out/apps/${value.appName}") apps
      ));

    passthru = old.passthru // {
      otherConfig = with lib.attrsets; with lib.lists; let
        zipped = zipAttrs ([old.otherConfig or {}] ++ map (v: v.otherConfig) apps);
      in
        {
          mimetypealiases = foldr (h: prev: prev // h) {} zipped.mimetypealiases;
          mimetypemapping = mapAttrs (_: v: unique (flatten v)) (zipAttrs zipped.mimetypemapping);
        };
      inherit apps;
      withApps = moreApps: old.withApps (moreApps ++ apps);
    };
  });

  package = stdenv.mkDerivation rec {
    name = "nextcloud-${version}";
    version = "16.0.0";

    src = fetchurl {
      url = "https://download.nextcloud.com/server/releases/${name}.tar.bz2";
      sha256 = "0bj014vczlrql1w32pqmr7cyqn9awnyzpi2syxhg16qxic1gfcj5";
    };

    installPhase = ''
      mkdir -p $out/
      cp -R . $out/
      rm -r $out/config
      ln -sf ${varDir}/config $out/config
      '';

    passthru = {
      apps = [];
      inherit otherConfig buildApp withApps varDir;
    };
    meta = {
      description = "Sharing solution for files, calendars, contacts and more";
      homepage = https://nextcloud.com;
      maintainers = with lib.maintainers; [ schneefux bachp globin fpletz ];
      license = lib.licenses.agpl3Plus;
      platforms = with lib.platforms; unix;
    };
  };
in package
