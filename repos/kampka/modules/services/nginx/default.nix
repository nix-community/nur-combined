{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.kampka.services.nginx;

in
{
  options.kampka.services.nginx = {
    enable = mkEnableOption "nginx";

    openFirewallPorts = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether or not to open the default ports (80, 443) in the firewall.
      '';
    };

    generateDhParams = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether or not to generate a dhparam key on nginx start if missing
      '';
    };

    dhParamBytes = mkOption {
      type = types.int;
      default = 4096;
      description = ''
        The size in bytes of the dhparams prime to be generated
      '';
    };
  };


  config = mkIf cfg.enable {

    services.nginx.enable = true;
    services.nginx.recommendedProxySettings = mkDefault true;
    services.nginx.recommendedOptimisation = mkDefault true;
    services.nginx.recommendedTlsSettings = mkDefault true;
    services.nginx.recommendedGzipSettings = mkDefault true;

    services.nginx.appendConfig = ''
      error_log stderr debug;
    '';

    # TODO-nixos-upgrade
    # The current defaults for ssl ciphers in NixOS are not compatible with TLSv1.2
    # See https://github.com/NixOS/nixpkgs/pull/80952
    # Until this is resolved, use recommended ciphers from Mozillas 
    # SSL configuration generator at https://ssl-config.mozilla.org/
    services.nginx.sslCiphers = mkDefault "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";

    # nginx needs a concrete resolver configured in order to contact the lets-encrypt
    # OCSP responder, which is required for certificate stapling to work
    services.nginx.resolver = mkIf config.kampka.services.dns-cache.enable (
      mkDefault {
        addresses = [ "127.0.0.1" ];
        valid = "5s";
      }
    );

    services.nginx.sslDhparam = mkIf cfg.generateDhParams (
      mkDefault
        "${config.services.nginx.stateDir}/dhparams-${toString cfg.dhParamBytes}.pem"
    );

    systemd.services.nginx.serviceConfig.TimeoutStartSec = "10 min";
    systemd.services.nginx.preStart = mkIf cfg.generateDhParams ''
      #!${pkgs.stdenv.shell}

      if [ ! -f "${config.services.nginx.stateDir}/dhparams-${toString cfg.dhParamBytes}.pem" ]; then
        ${pkgs.openssl}/bin/openssl dhparam -out "${config.services.nginx.stateDir}/dhparams-${toString cfg.dhParamBytes}.pem" ${toString cfg.dhParamBytes}
      fi
    '';
    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
