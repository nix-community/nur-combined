{ lib, pkgs, ... }:

with lib;
let
  bind_user = "admin";
  base_dn = "dc=example,dc=com";
  dn = "ou=people,${base_dn}";
  port = 3890;
  secure_port = 6360;
  host = "localhost";
  remote_host = "robocat";
in {
  config = {
    services.grafana.settings = {
      "auth.ldap" = {
        enabled = true;
        config_file = toString ((pkgs.formats.toml { }).generate "ldap.toml" ({
          servers = [{
            host = host;
            port = port;
            bind_dn = "uid=%s,${dn}";
            search_filter = "(uid=%s)";
            search_base_dns = [ base_dn ];
            attributes = {
              member_of = "memberOf";
              email = "mail";
              name = "displayName";
              surname = "sn";
              username = "uid";
            };
            group_mappings = [
              { group_dn = "cn=lldap_admin,ou=groups,dc=example,dc=com"; org_role = "Admin"; grafana_admin = true; }
              { group_dn = "cn=lldap_password_manager,ou=groups,dc=example,dc=com"; org_role = "Editor"; }
            ];
          }];
        }));
      };
    };
    services.syncthing.settings = {
      gui = {
        authMode = "ldap";
      };
      ldap = {
        address = "${host}:${toString port}";
        bindDN = "cn=%s,${dn}";
      };
    };
    services.open-webui.environment = {
      ENABLE_LDAP = "True";
      LDAP_SERVER_LABEL = "LDAP Server";
      LDAP_SERVER_HOST = remote_host;
      LDAP_SERVER_PORT = toString secure_port;
      LDAP_ATTRIBUTE_FOR_USERNAME = "uid";
      LDAP_APP_DN = "uid=${bind_user},${dn}";
      LDAP_SEARCH_BASE = dn;
      LDAP_SEARCH_FILTER = "(uid=*)";
      LDAP_USE_TLS = "True";
      LDAP_CA_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    };
    systemd.services.sftpgo.environment = {
      SFTPGO_PLUGINS__0__TYPE = "auth";
      SFTPGO_PLUGINS__0__AUTH_OPTIONS__SCOPE = "5";
      SFTPGO_PLUGINS__0__ARGS = "serve";
      SFTPGO_PLUGINS__0__AUTO_MTLS = "1";
      SFTPGO_PLUGIN_AUTH_LDAP_URL = "ldap://${host}:${toString port}";
      SFTPGO_PLUGIN_AUTH_LDAP_BASE_DN = base_dn;
      SFTPGO_PLUGIN_AUTH_LDAP_BIND_DN = "uid=${bind_user},${dn}";
      SFTPGO_PLUGIN_AUTH_LDAP_SEARCH_QUERY = "(&(objectClass=person)(|(uid=%%username%%)))";
    };
  };
}
