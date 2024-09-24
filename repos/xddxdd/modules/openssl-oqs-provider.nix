{
  config,
  pkgs,
  lib,
  ...
}:
let
  opensslConf = pkgs.writeText "openssl.conf" ''
    openssl_conf = openssl_init

    [openssl_init]
    providers = provider_sect
    ssl_conf = ssl_sect

    ### Providers

    [provider_sect]
    oqsprovider = oqsprovider_sect
    default = default_sect
    # fips = fips_sect

    [default_sect]
    activate = 1

    #[fips_sect]
    #activate = 1

    [oqsprovider_sect]
    activate = 1
    module = ${config.programs.openssl-oqs-provider.package}/lib/oqsprovider.so

    # SSL Options

    [ssl_sect]
    system_default = system_default_sect

    [system_default_sect]
    Groups = ${builtins.concatStringsSep ":" config.programs.openssl-oqs-provider.curves}
  '';
in
{
  options.programs.openssl-oqs-provider = {
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

  config = {
    environment.variables.OPENSSL_CONF = builtins.toString opensslConf;
  };
}
