{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf singleton;
  cfg = config.abszero.networking.supplicant;
in

{
  # School wifi is insecure :(
  options.abszero.networking.supplicant.enableInsecureSSLCiphers =
    mkEnableOption "insecure SSL ciphers";

  config = mkIf cfg.enableInsecureSSLCiphers {
    # Let wpa_supplicant use a version of openssl that supports weak SSL ciphers
    nixpkgs.overlays = singleton (
      _: prev:
      let
        openssl = prev.openssl.overrideAttrs (prev: {
          configureFlags = prev.configureFlags ++ singleton "enable-weak-ssl-ciphers";
        });
      in
      {
        wpa_supplicant = prev.wpa_supplicant.override { inherit openssl; };
      }
    );

    systemd.services."wpa_supplicant".serviceConfig.ExecStart = [
      "" # Clear the overridden ExecStart as it is additive
      "${pkgs.wpa_supplicant}/sbin/wpa_supplicant -u -i wlp1s0 -c /etc/wpa_supplicant.conf"
    ];

    environment.etc."wpa_supplicant.conf".text = ''
      openssl_ciphers=DEFAULT@SECLEVEL=0
    '';
  };
}
