{ config, pkgs, lib, ... }:
let
  inherit (pkgs) openldap;
  openldapCfg = config.services.openldap;
  secrets = config.sops.secrets;
  acmeCert = config.security.acme.certs."eh5.me";
  loadLdiff = dbDir: dn: ldiffile: pkgs.writeShellScript
    "openldap-load"
    ''
      rm -rf ${dbDir}
      mkdir -p ${dbDir}
      ${openldap}/bin/slapadd -F /etc/openldap/slapd.d -b '${dn}' \
        -l ${secrets."dc_eh5_dc_me.ldif".path}
    '';
in
{
  services.openldap = {
    enable = true;
    urlList = [ "ldap://localhost/" "ldaps:///" ];
  };
  services.openldap.settings = {
    attrs = {
      olcLogLevel = [ "0" ];
      olcTLSCertificateFile = "${acmeCert.directory}/cert.pem";
      olcTLSCertificateKeyFile = "${acmeCert.directory}/key.pem";
    };
    children = {
      "cn=schema".includes = [
        "${openldap}/etc/schema/core.ldif"
        "${openldap}/etc/schema/cosine.ldif"
        "${openldap}/etc/schema/inetorgperson.ldif"
        ./files/postfix-book.ldif
        ./files/mozilla-address-book.ldif
      ];
      "olcDatabase={-1}frontend" = {
        attrs = {
          objectClass = "olcDatabaseConfig";
          olcDatabase = "{-1}frontend";
          olcAccess = [ "{0}to * by * none" ];
        };
      };
      "olcDatabase={0}config" = {
        attrs = {
          objectClass = "olcDatabaseConfig";
          olcDatabase = "{0}config";
        };
      };
      "olcDatabase={1}mdb" = {
        attrs = {
          objectClass = [ "olcDatabaseConfig" "olcMdbConfig" ];
          olcDatabase = "{1}mdb";
          olcSuffix = "dc=eh5,dc=me";
          olcReadonly = "on"; # entries are preloaded from local file
          olcDbNosync = "TRUE";
          olcDbDirectory = "/var/lib/openldap/ldap";
          olcDbIndex = [
            "default pres,eq"
            "cn,mail,givenName,sn,telephoneNumber"
            "objectClass eq"
          ];
          olcRootDN = "cn=admin,dc=eh5,dc=me";
          olcRootPW = "{SSHA}S+qHqSgeYWUUyN81/VW7WiUZu3qac3kI";
          olcAccess = [ "{0}to * by self read by * auth" ];
        };
      };
    };
  };

  # similar to services.openldap.declarativeContents
  systemd.services.openldap.serviceConfig.ExecStartPre = lib.mkAfter [
    (loadLdiff "/var/lib/openldap/ldap" "dc=eh5,dc=me" secrets."dc_eh5_dc_me.ldif".path)
  ];

  users.users.${openldapCfg.user}.extraGroups = [ acmeCert.group ];
}
