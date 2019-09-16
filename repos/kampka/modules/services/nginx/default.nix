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
    services.nginx.recommendedProxySettings = true;
    services.nginx.recommendedOptimisation = true;
    services.nginx.recommendedTlsSettings = true;
    services.nginx.recommendedGzipSettings = true;

    services.nginx.appendConfig = ''
      error_log stderr debug;
    '';

    services.nginx.appendHttpConfig = ''
      add_header Strict-Transport-Security "max-age=15552000; includeSubDomains";
      # This will prevent certain click-jacking attacks, but will prevent
      # other sites from framing your site, so delete or modify as necessary!
      add_header X-Frame-Options "SAMEORIGIN";
      add_header Referrer-Policy "no-referrer";
      add_header X-XSS-Protection "1; mode=block";
      add_header X-Content-Type-Options "nosniff";
    '';

    services.nginx.sslDhparam = mkIf cfg.generateDhParams
      "${config.services.nginx.stateDir}/dhparams-${toString cfg.dhParamBytes}.pem"
    ;

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
