{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.security.openssl.oqs-provider;
in
{
  key = "xddxdd-nur-packages-openssl-oqs-provider";

  imports = [
    ./openssl-conf.nix
    (lib.mkRenamedOptionModule
      [ "programs" "openssl-oqs-provider" ]
      [ "security" "openssl" "oqs-provider" ]
    )
  ];

  options.security.openssl.oqs-provider = {
    enable = lib.mkEnableOption (lib.mdDoc "load post-quantum algorithm provider for OpenSSL 3.x") // {
      default = true;
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.openssl-oqs-provider;
      description = "Path to openssl-oqs-provider package";
    };
    curves = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "p256_frodo640aes"
        "x25519_frodo640aes"
        "p256_bikel1"
        "x25519_bikel1"
        "p256_kyber90s512"
        "x25519_kyber90s512"
        "prime256v1"
        "secp384r1"
        "x25519"
        "x448"
      ];
      description = "Enabled post-quantum algorithms";
    };
  };

  config = lib.mkIf cfg.enable {
    security.openssl = {
      enable = true;
      settings = {
        provider_sect.oqsprovider = "oqsprovider_sect";
        oqsprovider_sect = {
          activate = "1";
          module = "${cfg.package}/lib/oqsprovider.so";
        };

        openssl_init.ssl_conf = "ssl_sect";
        ssl_sect.system_default = "system_default_sect";
        system_default_sect.Groups = builtins.concatStringsSep ":" cfg.curves;
      };
    };
  };
}
