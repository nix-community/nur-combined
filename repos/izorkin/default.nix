{ pkgs ? import <nixpkgs> {} }:

rec {
  lib                 = import ./lib { inherit pkgs; };
  modules             = import ./modules;
  overlays            = import ./overlays;

  multichain          = pkgs.callPackage  ./pkgs/apps/altcoins/multichain.nix { };
  omnicore            = pkgs.callPackage  ./pkgs/apps/altcoins/omnicore.nix { };
  libssh2             = pkgs.callPackage  ./pkgs/development/libssh2 { openssl = pkgs.libressl; };
  mariadb             = pkgs.callPackage  ./pkgs/servers/mariadb { openssl = pkgs.libressl; asio = pkgs.asio_1_10; jemalloc = pkgs.jemalloc450.override ({ disableInitExecTls = true; }); inherit (pkgs.darwin) cctools; inherit (pkgs.darwin.apple_sdk.frameworks) CoreServices; };
  unit                = pkgs.callPackage  ./pkgs/servers/unit { openssl = pkgs.libressl; php56 = php56-unit; php71 = php71-unit; php72 = php72-unit; php73 = php73-unit; withPython = false; withPHP56 = true; withPHP71 = true; withPHP72 = true; withPHP73 = true; withPerl = false; withPerldevel = false; withRuby_2_3 = false; withRuby_2_4 = false; withRuby = false; withSSL = true; withIPv6 = false; withDebug = false; };
  oh-my-zsh-custom    = pkgs.callPackage  ./pkgs/shells/oh-my-zsh-custom { inherit zsh-theme-rkj-mod; };
  zsh-theme-rkj-mod   = pkgs.callPackage  ./pkgs/shells/zsh-theme-rkj-mod { };
  curl                = pkgs.callPackage  ./pkgs/tools/curl { openssl = pkgs.libressl; inherit libssh2; brotliSupport = true; scpSupport = true; sslSupport = true; zlibSupport = true; };
  fail2ban            = pkgs.callPackage  ./pkgs/tools/fail2ban { };

  inherit              (pkgs.callPackages ./pkgs/development/php { openssl = pkgs.libressl; inherit curl; config.php.ldap = false; config.php.pdo_odbc = false; config.php.postgresql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; }) php56 php71 php72 php73;

  php56-unit          = php56.override { config.php.ldap = false; config.php.pdo_odbc = false; config.php.postgresql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; config.php.embed = true; config.php.apxs2 = false; config.php.systemd = false; config.php.fpm = false; };
  php71-unit          = php71.override { config.php.ldap = false; config.php.pdo_odbc = false; config.php.postgresql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; config.php.embed = true; config.php.apxs2 = false; config.php.systemd = false; config.php.fpm = false; };
  php72-unit          = php72.override { config.php.ldap = false; config.php.pdo_odbc = false; config.php.postgresql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; config.php.embed = true; config.php.apxs2 = false; config.php.systemd = false; config.php.fpm = false; };
  php73-unit          = php73.override { config.php.ldap = false; config.php.pdo_odbc = false; config.php.postgresql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; config.php.embed = true; config.php.apxs2 = false; config.php.systemd = false; config.php.fpm = false; };

  php56Packages       = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php56-packages.nix { php = php56; });
  php56Packages-unit  = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php56-packages.nix { php = php56-unit; });
  php71Packages-unit  = pkgs.php71Packages.override { php = php71-unit; };
  php72Packages-unit  = pkgs.php72Packages.override { php = php72-unit; };
  php73Packages-unit  = pkgs.php73Packages.override { php = php73-unit; };

  php-info            = pkgs.callPackage  ./pkgs/web/php-info { };
  php-bench           = pkgs.callPackage  ./pkgs/web/php-bench { };
}
