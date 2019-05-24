{ siteName ? "spip"
, siteDir ? runCommand "empty" { preferLocalBuild = true; } "mkdir -p $out"
, environment ? "prod"
, ldap ? false
, varDir ? "/var/lib/${siteName}_${environment}"
, lib, fetchzip, runCommand, stdenv }:
let
  app = stdenv.mkDerivation rec {
    name = "${siteName}-${environment}-spip-${version}";
    version = "3.2.3";
    src = fetchzip {
      url = "https://files.spip.net/spip/archives/SPIP-v${version}.zip";
      sha256 = "1r1mjvsnrp6mvkgjakvi3x4ms8m8k5mp93micbbg8r99fj7qlfkq";
    };
    paches = lib.optionals ldap [ ./spip_ldap_patch.patch ];
    buildPhase = ''
      rm -rf IMG local tmp config/remove.txt
      ln -sf ${./spip_mes_options.php} config/mes_options.php
      echo "Require all denied" > "config/.htaccess"
      ln -sf ${varDir}/{IMG,local} .
    '';
    installPhase = ''
      cp -a . $out
      cp -a ${siteDir}/* $out
    '';
    passthru = {
      inherit siteName siteDir environment varDir;
      webRoot = app;
      spipConfig = ./spip_mes_options.php;
    };
  };
in app
