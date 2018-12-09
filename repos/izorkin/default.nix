{ pkgs ? import <nixpkgs> {} }:

rec {
  lib              = import ./lib { inherit pkgs; };
  modules          = import ./modules;
  overlays         = import ./overlays;

  multichain       = pkgs.callPackage ./pkgs/apps/altcoins/multichain.nix { };
  omnicore         = pkgs.callPackage ./pkgs/apps/altcoins/omnicore.nix { };
  libssh2          = pkgs.callPackage ./pkgs/development/libssh2 { openssl = pkgs.libressl; };
  mariadb          = pkgs.callPackage ./pkgs/servers/mariadb { openssl = pkgs.libressl; asio = pkgs.asio_1_10; inherit (pkgs.darwin) cctools; inherit (pkgs.darwin.apple_sdk.frameworks) CoreServices; };
  oh-my-zsh-custom = pkgs.callPackage ./pkgs/shells/oh-my-zsh-custom { };
  curl             = pkgs.callPackage ./pkgs/tools/curl { openssl = pkgs.libressl; inherit libssh2; brotliSupport = true; scpSupport = true; sslSupport = true; zlibSupport = true; };
  fail2ban         = pkgs.callPackage ./pkgs/tools/fail2ban { };

  inherit           (pkgs.callPackages ./pkgs/development/php { openssl = pkgs.libressl; inherit curl; config.php.ldap = false; config.php.postgresql = false; config.php.pdo_pgsql = false; config.php.mssql = false; config.php.zts = true; }) php56 php71 php72 php73;
  php56Packages    = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/development/php/php56-packages.nix { php = php56; });

}
