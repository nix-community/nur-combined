{ pkgs ? import <nixpkgs> {} }:

rec {
  lib                 = import ./lib { inherit pkgs; };
  modules             = import ./modules;
  overlays            = import ./overlays;

  asio_1_10           = pkgs.callPackage  ./pkgs/development/asio/1.10.nix { };
  bison2              = pkgs.callPackage  ./pkgs/development/bison2 { };
  libcouchbase_2_10_4 = pkgs.callPackage  ./pkgs/development/libcouchbase/2.10.4.nix { openssl = pkgs.libressl; };
  libssh2             = pkgs.callPackage  ./pkgs/development/libssh2 { openssl = pkgs.libressl; };
  libxml2_2_12        = pkgs.callPackage  ./pkgs/development/libxml2/2.12.nix { };
  spidermonkey_1_8_5  = pkgs.callPackage  ./pkgs/development/spidermonkey/1.8.5.nix { stdenv = pkgs.gcc13Stdenv; };
  mariadb_10_5        = pkgs.callPackage  ./pkgs/servers/mariadb/mariadb_10_5.nix { openssl = pkgs.libressl; inherit curl; inherit (pkgs.darwin) cctools; inherit (pkgs.darwin.apple_sdk.frameworks) CoreServices; };
  mariadb_10_6        = pkgs.callPackage  ./pkgs/servers/mariadb/mariadb_10_6.nix { openssl = pkgs.libressl; inherit curl; inherit (pkgs.darwin) cctools; inherit (pkgs.darwin.apple_sdk.frameworks) CoreServices; };
  mariadb-galera_25   = pkgs.callPackage  ./pkgs/servers/mariadb/galera_25.nix { asio = asio_1_10; };
  mariadb-galera_26   = pkgs.callPackage  ./pkgs/servers/mariadb/galera_26.nix { asio = pkgs.asio_1_32_0; };
  unit                = pkgs.callPackage  ./pkgs/servers/unit { openssl = pkgs.libressl; php56 = php56-unit; php71 = php71-unit; php72 = php72-unit; php73 = php73-unit; php74 = php74-unit; php80 = php80-unit; php81 = php81-unit; php82 = php82-unit; withPython3 = false; withPHP56 = true; withPHP71 = true; withPHP72 = true; withPHP73 = true; withPHP74 = true; withPHP80 = true; withPHP81 = true; withPHP82 = true; withPerl = false; withRuby_3_1 = false; withIPv6 = true; };
  oh-my-zsh-custom    = pkgs.callPackage  ./pkgs/shells/oh-my-zsh-custom { inherit zsh-history-sync; inherit zsh-theme-rkj-mod; };
  zsh-history-sync    = pkgs.callPackage  ./pkgs/shells/zsh-history-sync { };
  zsh-theme-rkj-mod   = pkgs.callPackage  ./pkgs/shells/zsh-theme-rkj-mod { };
  curl                = pkgs.callPackage  ./pkgs/tools/curl { openssl = pkgs.libressl; inherit libssh2; brotliSupport = true; idnSupport = true; pslSupport = true; websocketSupport = true; zstdSupport = true; };
  fail2ban            = pkgs.callPackage  ./pkgs/tools/fail2ban { };
  uwimap              = pkgs.callPackage  ./pkgs/tools/uwimap { openssl = pkgs.libressl; };

  inherit              (pkgs.callPackages ./pkgs/development/libressl { }) libressl_3_8;

  php-pearweb-phars   = pkgs.callPackage  ./pkgs/development/php/pearweb-phars.nix { };
  inherit              (pkgs.callPackages ./pkgs/development/php { openssl = libressl_3_8;  inherit bison2; inherit libxml2_2_12; curl = curl.override ({ openssl = libressl_3_8; libssh2 = libssh2.override ({ openssl = libressl_3_8; }); }); uwimap = uwimap.override ({ openssl = libressl_3_8; }); inherit php-pearweb-phars; config.php.ldap = false; config.php.pdo_odbc = false; config.php.pgsql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; }) php56 php71 php72 php73 php74 php80;
  inherit              (pkgs.callPackages ./pkgs/development/php { openssl = pkgs.libressl; inherit bison2; inherit libxml2_2_12; inherit curl; inherit uwimap; inherit php-pearweb-phars; config.php.ldap = false; config.php.pdo_odbc = false; config.php.pgsql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; }) php81 php82;

  php56-unit          = php56.override { config.php.ldap = false; config.php.pdo_odbc = false; config.php.pgsql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; config.php.ipv6 = true; config.php.embed = true; config.php.apxs2 = false; config.php.systemd = false; config.php.phpdbg = false; config.php.cgi = false; config.php.fpm = false; };
  php71-unit          = php71.override { config.php.ldap = false; config.php.pdo_odbc = false; config.php.pgsql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; config.php.ipv6 = true; config.php.embed = true; config.php.apxs2 = false; config.php.systemd = false; config.php.phpdbg = false; config.php.cgi = false; config.php.fpm = false; };
  php72-unit          = php72.override { config.php.ldap = false; config.php.pdo_odbc = false; config.php.pgsql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; config.php.ipv6 = true; config.php.embed = true; config.php.apxs2 = false; config.php.systemd = false; config.php.phpdbg = false; config.php.cgi = false; config.php.fpm = false; };
  php73-unit          = php73.override { config.php.ldap = false; config.php.pdo_odbc = false; config.php.pgsql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; config.php.ipv6 = true; config.php.embed = true; config.php.apxs2 = false; config.php.systemd = false; config.php.phpdbg = false; config.php.cgi = false; config.php.fpm = false; };
  php74-unit          = php74.override { config.php.ldap = false; config.php.pdo_odbc = false; config.php.pgsql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; config.php.ipv6 = true; config.php.embed = true; config.php.apxs2 = false; config.php.systemd = false; config.php.phpdbg = false; config.php.cgi = false; config.php.fpm = false; };
  php80-unit          = php80.override { config.php.ldap = false; config.php.pdo_odbc = false; config.php.pgsql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; config.php.ipv6 = true; config.php.embed = true; config.php.apxs2 = false; config.php.systemd = false; config.php.phpdbg = false; config.php.cgi = false; config.php.fpm = false; };
  php81-unit          = php81.override { config.php.ldap = false; config.php.pdo_odbc = false; config.php.pgsql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; config.php.ipv6 = true; config.php.embed = true; config.php.apxs2 = false; config.php.systemd = false; config.php.phpdbg = false; config.php.cgi = false; config.php.fpm = false; };
  php82-unit          = php82.override { config.php.ldap = false; config.php.pdo_odbc = false; config.php.pgsql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; config.php.ipv6 = true; config.php.embed = true; config.php.apxs2 = false; config.php.systemd = false; config.php.phpdbg = false; config.php.cgi = false; config.php.fpm = false; };

  php56Packages       = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php56;      openssl = libressl_3_8;  libevent = pkgs.libevent.override ({ openssl = libressl_3_8; });  libcouchbase_2_10_4 = libcouchbase_2_10_4.override ({ openssl = libressl_3_8; }); inherit spidermonkey_1_8_5; });
  php71Packages       = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php71;      openssl = libressl_3_8;  libevent = pkgs.libevent.override ({ openssl = libressl_3_8; });  libcouchbase_2_10_4 = libcouchbase_2_10_4.override ({ openssl = libressl_3_8; }); inherit spidermonkey_1_8_5; });
  php72Packages       = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php72;      openssl = libressl_3_8;  libevent = pkgs.libevent.override ({ openssl = libressl_3_8; });  libcouchbase_2_10_4 = libcouchbase_2_10_4.override ({ openssl = libressl_3_8; }); inherit spidermonkey_1_8_5; });
  php73Packages       = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php73;      openssl = libressl_3_8;  libevent = pkgs.libevent.override ({ openssl = libressl_3_8; });  libcouchbase_2_10_4 = libcouchbase_2_10_4.override ({ openssl = libressl_3_8; }); inherit spidermonkey_1_8_5; });
  php74Packages       = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php74;      openssl = libressl_3_8;  libevent = pkgs.libevent.override ({ openssl = libressl_3_8; });  libcouchbase_2_10_4 = libcouchbase_2_10_4.override ({ openssl = libressl_3_8; }); inherit spidermonkey_1_8_5; });
  php80Packages       = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php80;      openssl = libressl_3_8;  libevent = pkgs.libevent.override ({ openssl = libressl_3_8; });  libcouchbase_2_10_4 = libcouchbase_2_10_4.override ({ openssl = libressl_3_8; }); inherit spidermonkey_1_8_5; });
  php81Packages       = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php81;      openssl = pkgs.libressl; libevent = pkgs.libevent.override ({ openssl = pkgs.libressl; }); inherit libcouchbase_2_10_4; inherit spidermonkey_1_8_5; });
  php82Packages       = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php82;      openssl = pkgs.libressl; libevent = pkgs.libevent.override ({ openssl = pkgs.libressl; }); inherit libcouchbase_2_10_4; inherit spidermonkey_1_8_5; });
  php56Packages-unit  = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php56-unit; openssl = libressl_3_8;  libevent = pkgs.libevent.override ({ openssl = libressl_3_8; });  libcouchbase_2_10_4 = libcouchbase_2_10_4.override ({ openssl = libressl_3_8; }); inherit spidermonkey_1_8_5; });
  php71Packages-unit  = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php71-unit; openssl = libressl_3_8;  libevent = pkgs.libevent.override ({ openssl = libressl_3_8; });  libcouchbase_2_10_4 = libcouchbase_2_10_4.override ({ openssl = libressl_3_8; }); inherit spidermonkey_1_8_5; });
  php72Packages-unit  = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php72-unit; openssl = libressl_3_8;  libevent = pkgs.libevent.override ({ openssl = libressl_3_8; });  libcouchbase_2_10_4 = libcouchbase_2_10_4.override ({ openssl = libressl_3_8; }); inherit spidermonkey_1_8_5; });
  php73Packages-unit  = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php73-unit; openssl = libressl_3_8;  libevent = pkgs.libevent.override ({ openssl = libressl_3_8; });  libcouchbase_2_10_4 = libcouchbase_2_10_4.override ({ openssl = libressl_3_8; }); inherit spidermonkey_1_8_5; });
  php74Packages-unit  = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php74-unit; openssl = libressl_3_8;  libevent = pkgs.libevent.override ({ openssl = libressl_3_8; });  libcouchbase_2_10_4 = libcouchbase_2_10_4.override ({ openssl = libressl_3_8; }); inherit spidermonkey_1_8_5; });
  php80Packages-unit  = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php80-unit; openssl = libressl_3_8;  libevent = pkgs.libevent.override ({ openssl = libressl_3_8; });  libcouchbase_2_10_4 = libcouchbase_2_10_4.override ({ openssl = libressl_3_8; }); inherit spidermonkey_1_8_5; });
  php81Packages-unit  = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php81-unit; openssl = pkgs.libressl; libevent = pkgs.libevent.override ({ openssl = pkgs.libressl; }); inherit libcouchbase_2_10_4; inherit spidermonkey_1_8_5; });
  php82Packages-unit  = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php82-unit; openssl = pkgs.libressl; libevent = pkgs.libevent.override ({ openssl = pkgs.libressl; }); inherit libcouchbase_2_10_4; inherit spidermonkey_1_8_5; });

  php-bench           = pkgs.callPackage  ./pkgs/web/php-bench { };
  php-info            = pkgs.callPackage  ./pkgs/web/php-info { };
  php-prober          = pkgs.callPackage  ./pkgs/web/php-prober { };
}
