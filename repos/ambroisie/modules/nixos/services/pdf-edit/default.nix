{ config, lib, ... }:
let
  cfg = config.my.services.pdf-edit;
in
{
  options.my.services.pdf-edit = with lib; {
    enable = mkEnableOption "PDF edition service";

    port = mkOption {
      type = types.port;
      default = 8089;
      example = 8080;
      description = "Internal port for webui";
    };

    loginFile = mkOption {
      type = types.str;
      example = "/run/secrets/pdf-edit/login.env";
      description = ''
        `SECURITY_INITIALLOGIN_USERNAME` and `SECURITY_INITIALLOGIN_PASSWORD`
        defined in the format of 'EnvironmentFile' (see `systemd.exec(5)`).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.stirling-pdf = lib.mkIf cfg.enable {
      enable = true;

      environment = {
        SERVER_PORT = cfg.port;
        SECURITY_CSRFDISABLED = "false";

        SYSTEM_SHOWUPDATE = "false"; # We don't care about update notifications
        INSTALL_BOOK_AND_ADVANCED_HTML_OPS = "true"; # Installed by the module

        SECURITY_ENABLELOGIN = "true";
        SECURITY_LOGINATTEMPTCOUNT = "-1"; # Rely on fail2ban instead
      };

      environmentFiles = [ cfg.loginFile ];
    };

    my.services.nginx.virtualHosts = {
      pdf-edit = {
        inherit (cfg) port;

        extraConfig = {
          # Allow upload of PDF files up to 1G
          locations."/".extraConfig = ''
            client_max_body_size 1G;
          '';
        };
      };
    };

    services.fail2ban.jails = {
      stirling-pdf = ''
        enabled = true
        filter = stirling-pdf
        port = http,https
      '';
    };

    environment.etc = {
      "fail2ban/filter.d/stirling-pdf.conf".text = ''
        [Definition]
        failregex = ^.*Failed login attempt from IP: <HOST>$
        journalmatch = _SYSTEMD_UNIT=stirling-pdf.service
      '';
    };
  };
}
