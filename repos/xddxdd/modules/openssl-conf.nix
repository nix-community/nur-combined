{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.security.openssl;
  opensslConfIni = lib.generators.toINI { } cfg.settings;
  opensslConfFile = pkgs.writeText "openssl.conf" ''
    openssl_conf = openssl_init
    ${opensslConfIni}
  '';
in
{
  options.security.openssl = {
    enable = lib.mkEnableOption (lib.mdDoc "Specify settings (OPENSSL_CONF) for OpenSSL") // {
      default = true;
    };
    enableDefaultProvider = lib.mkEnableOption (lib.mdDoc "Enable default cryptography provider") // {
      default = true;
    };
    enableLegacyProvider = lib.mkEnableOption (lib.mdDoc "Enable legacy cryptography provider");
    enableFIPSProvider = lib.mkEnableOption (lib.mdDoc "Enable FIPS cryptography provider");
    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "OpenSSL settings";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf cfg.enableDefaultProvider {
        security.openssl.settings = {
          openssl_init.providers = "provider_sect";
          provider_sect.default = "default_sect";
          default_sect.activate = "1";
        };
      })
      (lib.mkIf cfg.enableLegacyProvider {
        security.openssl.settings = {
          openssl_init.providers = "provider_sect";
          provider_sect.legacy = "legacy_sect";
          legacy_sect.activate = "1";
        };
      })
      (lib.mkIf cfg.enableFIPSProvider {
        security.openssl.settings = {
          openssl_init.providers = "provider_sect";
          provider_sect.fips = "fips_sect";
          fips_sect.activate = "1";
        };
      })
      {
        environment.variables.OPENSSL_CONF = builtins.toString opensslConfFile;
      }
    ]
  );
}
