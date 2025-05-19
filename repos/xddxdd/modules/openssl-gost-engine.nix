{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.security.openssl.gost-engine;
in
{
  key = "xddxdd-nur-packages-openssl-gost-engine";

  imports = [ ./openssl-conf.nix ];

  options.security.openssl.gost-engine = {
    enable = lib.mkEnableOption (lib.mdDoc "load GOST provider for OpenSSL 3.x") // {
      default = true;
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.gost-engine;
      description = "Path to gost-engine package";
    };
  };

  config = lib.mkIf cfg.enable {
    security.openssl = {
      enable = true;
      settings = {
        provider_sect.gostprovider = "gostprovider_sect";
        gostprovider_sect = {
          activate = "1";
          module = "${cfg.package}/lib/ossl-modules/gostprov.so";
        };
      };
    };
  };
}
