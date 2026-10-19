{ lib, ... }:
let
  mkService = import ../../../lib/mkService.nix;
in
mkService {
  name = "lldap";
  description = "LLDAP Authentication Service";
  defaultPort = 17170;
  runtime = "container";
  defaultImage = "lldap/lldap:stable";

  extraOptions =
    { lib, ... }:
    {
      ldapBaseDn = lib.mkOption {
        type = lib.types.str;
        example = "dc=example,dc=com";
        description = "Base DN for LDAP queries (required).";
      };

      ldapPort = lib.mkOption {
        type = lib.types.port;
        default = 3890;
        description = "LDAP server port.";
      };

      adminUser = lib.mkOption {
        type = lib.types.str;
        default = "admin";
        description = "Admin username for LDAP interface.";
      };

      adminEmail = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Admin email address.";
      };

      httpUrl = lib.mkOption {
        type = lib.types.str;
        default = "http://localhost";
        description = "Public URL for password reset links.";
      };

      smtp = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.submodule {
            options = {
              host = lib.mkOption {
                type = lib.types.str;
                description = "SMTP host.";
              };
              port = lib.mkOption {
                type = lib.types.int;
                default = 587;
              };
              user = lib.mkOption {
                type = lib.types.str;
                default = "";
              };
              password = lib.mkOption {
                type = lib.types.str;
                default = "";
              };
              from = lib.mkOption {
                type = lib.types.str;
                description = "From address.";
              };
              encryption = lib.mkOption {
                type = lib.types.enum [
                  "NONE"
                  "TLS"
                  "STARTTLS"
                ];
                default = "TLS";
              };
            };
          }
        );
        default = null;
        description = "SMTP configuration for password reset emails.";
      };

      ldaps = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.submodule {
            options = {
              certPath = lib.mkOption {
                type = lib.types.str;
                description = "Path to certificate.";
              };
              keyPath = lib.mkOption {
                type = lib.types.str;
                description = "Path to key file.";
              };
            };
          }
        );
        default = null;
        description = "Enable LDAPS with certificate.";
      };

      verbose = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable verbose logging.";
      };
    };

  extraConfig = cfg: {
    homelab.services.lldap.container = {
      ports = [
        "${toString cfg.port}:${toString cfg.port}"
        "${toString cfg.ldapPort}:${toString cfg.ldapPort}"
      ];
      volumes = [ "${cfg.dataDir}:/data" ];
    };

    homelab.services.lldap.environment = {
      LLDAP_LDAP_BASE_DN = cfg.ldapBaseDn;
      LLDAP_LDAP_PORT = toString cfg.ldapPort;
      LLDAP_HTTP_PORT = toString cfg.port;
      LLDAP_HTTP_URL = cfg.httpUrl;
      LLDAP_LDAP_USER_DN = cfg.adminUser;
      LLDAP_VERBOSE = lib.boolToString cfg.verbose;
    }
    // lib.optionalAttrs (cfg.adminEmail != "") {
      LLDAP_LDAP_USER_EMAIL = cfg.adminEmail;
    }
    // lib.optionalAttrs (cfg.smtp != null) {
      LLDAP_SMTP_OPTIONS__HOST = cfg.smtp.host;
      LLDAP_SMTP_OPTIONS__PORT = toString cfg.smtp.port;
      LLDAP_SMTP_OPTIONS__USER = cfg.smtp.user;
      LLDAP_SMTP_OPTIONS__PASSWORD = cfg.smtp.password;
      LLDAP_SMTP_OPTIONS__FROM = cfg.smtp.from;
      LLDAP_SMTP_OPTIONS__SMTP_ENCRYPTION = cfg.smtp.encryption;
      LLDAP_SMTP_OPTIONS__ENABLE_PASSWORD_RESET = "true";
    }
    // lib.optionalAttrs (cfg.ldaps != null) {
      LLDAP_LDAPS_OPTIONS__ENABLED = "true";
      LLDAP_LDAPS_OPTIONS__CERT_PATH = cfg.ldaps.certPath;
      LLDAP_LDAPS_OPTIONS__KEY_PATH = cfg.ldaps.keyPath;
    };
  };
}
