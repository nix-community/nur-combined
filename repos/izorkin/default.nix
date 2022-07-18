{ pkgs ? import <nixpkgs> {} }:

rec {
  lib                 = import ./lib { inherit pkgs; };
  modules             = import ./modules;
  overlays            = import ./overlays;

  bison2              = pkgs.callPackage  ./pkgs/development/bison2 { };
  jemalloc450         = pkgs.callPackage  ./pkgs/development/jemalloc/4.5.0.nix { };
  libcouchbase_2_10_4 = pkgs.callPackage  ./pkgs/development/libcouchbase/2.10.4.nix { openssl = pkgs.libressl; };
  libssh2             = pkgs.callPackage  ./pkgs/development/libssh2 { openssl = pkgs.libressl; };
  spidermonkey_1_8_5  = pkgs.callPackage  ./pkgs/development/spidermonkey/1.8.5.nix { };
  mariadb_10_3        = pkgs.callPackage  ./pkgs/servers/mariadb/mariadb_10_3.nix { openssl = pkgs.libressl; inherit curl; inherit (pkgs.darwin) cctools; inherit (pkgs.darwin.apple_sdk.frameworks) CoreServices; jemalloc450 = jemalloc450.override ({ disableInitExecTls = true; }); };
  mariadb_10_4        = pkgs.callPackage  ./pkgs/servers/mariadb/mariadb_10_4.nix { openssl = pkgs.libressl; inherit curl; inherit (pkgs.darwin) cctools; inherit (pkgs.darwin.apple_sdk.frameworks) CoreServices; jemalloc450 = jemalloc450.override ({ disableInitExecTls = true; }); };
  mariadb_10_5        = pkgs.callPackage  ./pkgs/servers/mariadb/mariadb_10_5.nix { openssl = pkgs.libressl; inherit curl; inherit (pkgs.darwin) cctools; inherit (pkgs.darwin.apple_sdk.frameworks) CoreServices; };
  mariadb_10_6        = pkgs.callPackage  ./pkgs/servers/mariadb/mariadb_10_6.nix { openssl = pkgs.libressl; inherit curl; inherit (pkgs.darwin) cctools; inherit (pkgs.darwin.apple_sdk.frameworks) CoreServices; };
  mariadb_10_7        = pkgs.callPackage  ./pkgs/servers/mariadb/mariadb_10_7.nix { openssl = pkgs.libressl; inherit curl; inherit (pkgs.darwin) cctools; inherit (pkgs.darwin.apple_sdk.frameworks) CoreServices; };
  mariadb-galera_25   = pkgs.callPackage  ./pkgs/servers/mariadb/galera_25.nix { asio = pkgs.asio_1_10; };
  mariadb-galera_26   = pkgs.callPackage  ./pkgs/servers/mariadb/galera_26.nix { asio = pkgs.asio_1_10; };
  mysql_5_5           = pkgs.callPackage  ./pkgs/servers/mysql/mysql_5_5.nix { openssl = pkgs.libressl; inherit (pkgs.darwin) cctools; inherit (pkgs.darwin.apple_sdk.frameworks) CoreServices; };
  unit                = pkgs.callPackage  ./pkgs/servers/unit { openssl = pkgs.libressl; php56 = php56-unit; php71 = php71-unit; php72 = php72-unit; php73 = php73-unit; php74 = php74-unit; php80 = php80-unit; php81 = php81-unit; withPython3 = false; withPHP56 = true; withPHP71 = true; withPHP72 = true; withPHP73 = true; withPHP74 = true; withPHP80 = true; withPHP81 = true; withPerl534 = false; withRuby_3_0 = false; withIPv6 = true; };
  oh-my-zsh-custom    = pkgs.callPackage  ./pkgs/shells/oh-my-zsh-custom { inherit zsh-history-sync; inherit zsh-theme-rkj-mod; };
  zsh-history-sync    = pkgs.callPackage  ./pkgs/shells/zsh-history-sync { };
  zsh-theme-rkj-mod   = pkgs.callPackage  ./pkgs/shells/zsh-theme-rkj-mod { };
  curl                = pkgs.callPackage  ./pkgs/tools/curl { openssl = pkgs.libressl; inherit libssh2; brotliSupport = true; idnSupport = true; zstdSupport = true; };
  fail2ban            = pkgs.callPackage  ./pkgs/tools/fail2ban { };
  uwimap              = pkgs.callPackage  ./pkgs/tools/uwimap { openssl = pkgs.libressl; };

  php-pearweb-phars   = pkgs.callPackage  ./pkgs/development/php/pearweb-phars.nix { };
  inherit              (pkgs.callPackages ./pkgs/development/php { openssl = pkgs.libressl; inherit bison2; inherit curl; inherit uwimap; inherit php-pearweb-phars; config.php.ldap = false; config.php.pdo_odbc = false; config.php.pgsql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; }) php56 php71 php72 php73 php74 php80 php81;

  php56-unit          = php56.override { config.php.ldap = false; config.php.pdo_odbc = false; config.php.postgresql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; config.php.ipv6 = true; config.php.embed = true; config.php.apxs2 = false; config.php.systemd = false; config.php.phpdbg = false; config.php.cgi = false; config.php.fpm = false; };
  php71-unit          = php71.override { config.php.ldap = false; config.php.pdo_odbc = false; config.php.postgresql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; config.php.ipv6 = true; config.php.embed = true; config.php.apxs2 = false; config.php.systemd = false; config.php.phpdbg = false; config.php.cgi = false; config.php.fpm = false; };
  php72-unit          = php72.override { config.php.ldap = false; config.php.pdo_odbc = false; config.php.postgresql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; config.php.ipv6 = true; config.php.embed = true; config.php.apxs2 = false; config.php.systemd = false; config.php.phpdbg = false; config.php.cgi = false; config.php.fpm = false; };
  php73-unit          = php73.override { config.php.ldap = false; config.php.pdo_odbc = false; config.php.postgresql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; config.php.ipv6 = true; config.php.embed = true; config.php.apxs2 = false; config.php.systemd = false; config.php.phpdbg = false; config.php.cgi = false; config.php.fpm = false; };
  php74-unit          = php74.override { config.php.ldap = false; config.php.pdo_odbc = false; config.php.postgresql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; config.php.ipv6 = true; config.php.embed = true; config.php.apxs2 = false; config.php.systemd = false; config.php.phpdbg = false; config.php.cgi = false; config.php.fpm = false; };
  php80-unit          = php80.override { config.php.ldap = false; config.php.pdo_odbc = false; config.php.postgresql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; config.php.ipv6 = true; config.php.embed = true; config.php.apxs2 = false; config.php.systemd = false; config.php.phpdbg = false; config.php.cgi = false; config.php.fpm = false; };
  php81-unit          = php81.override { config.php.ldap = false; config.php.pdo_odbc = false; config.php.postgresql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; config.php.ipv6 = true; config.php.embed = true; config.php.apxs2 = false; config.php.systemd = false; config.php.phpdbg = false; config.php.cgi = false; config.php.fpm = false; };

  php56Packages       = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php56;      openssl = pkgs.libressl; libevent = pkgs.libevent.override ({ openssl = pkgs.libressl; }); inherit libcouchbase_2_10_4; inherit spidermonkey_1_8_5; });
  php71Packages       = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php71;      openssl = pkgs.libressl; libevent = pkgs.libevent.override ({ openssl = pkgs.libressl; }); inherit libcouchbase_2_10_4; });
  php72Packages       = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php72;      openssl = pkgs.libressl; libevent = pkgs.libevent.override ({ openssl = pkgs.libressl; }); inherit libcouchbase_2_10_4; });
  php73Packages       = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php73;      openssl = pkgs.libressl; libevent = pkgs.libevent.override ({ openssl = pkgs.libressl; }); inherit libcouchbase_2_10_4; });
  php74Packages       = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php74;      openssl = pkgs.libressl; libevent = pkgs.libevent.override ({ openssl = pkgs.libressl; }); inherit libcouchbase_2_10_4; });
  php80Packages       = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php80;      openssl = pkgs.libressl; libevent = pkgs.libevent.override ({ openssl = pkgs.libressl; }); inherit libcouchbase_2_10_4; });
  php81Packages       = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php81;      openssl = pkgs.libressl; libevent = pkgs.libevent.override ({ openssl = pkgs.libressl; }); inherit libcouchbase_2_10_4; });
  php56Packages-unit  = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php56-unit; openssl = pkgs.libressl; libevent = pkgs.libevent.override ({ openssl = pkgs.libressl; }); inherit libcouchbase_2_10_4; inherit spidermonkey_1_8_5; });
  php71Packages-unit  = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php71-unit; openssl = pkgs.libressl; libevent = pkgs.libevent.override ({ openssl = pkgs.libressl; }); inherit libcouchbase_2_10_4; });
  php72Packages-unit  = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php72-unit; openssl = pkgs.libressl; libevent = pkgs.libevent.override ({ openssl = pkgs.libressl; }); inherit libcouchbase_2_10_4; });
  php73Packages-unit  = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php73-unit; openssl = pkgs.libressl; libevent = pkgs.libevent.override ({ openssl = pkgs.libressl; }); inherit libcouchbase_2_10_4; });
  php74Packages-unit  = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php74-unit; openssl = pkgs.libressl; libevent = pkgs.libevent.override ({ openssl = pkgs.libressl; }); inherit libcouchbase_2_10_4; });
  php80Packages-unit  = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php80-unit; openssl = pkgs.libressl; libevent = pkgs.libevent.override ({ openssl = pkgs.libressl; }); inherit libcouchbase_2_10_4; });
  php81Packages-unit  = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php-packages.nix { php = php81-unit; openssl = pkgs.libressl; libevent = pkgs.libevent.override ({ openssl = pkgs.libressl; }); inherit libcouchbase_2_10_4; });

  php-bench           = pkgs.callPackage  ./pkgs/web/php-bench { };
  php-info            = pkgs.callPackage  ./pkgs/web/php-info { };
  php-prober          = pkgs.callPackage  ./pkgs/web/php-prober { };
}
