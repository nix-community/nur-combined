{ config, pkgs, lib, ... }:
let
  cfg = config.mail;
  secrets = config.sops.secrets;
in
{
  nixpkgs.overlays = [
    (final: prev: {
      sogo = (prev.sogo.override { enableActiveSync = true; }).overrideAttrs (_: attrs: rec {
        version = assert attrs.version == "5.7.0"; "5.7.1";
        src = pkgs.fetchFromGitHub {
          owner = "inverse-inc";
          repo = attrs.pname;
          rev = "SOGo-${version}";
          hash = "sha256-GCgnguNZ02HyRZoy8Rivl+LSxe6HCqv/Wqyj4oYST4U=";
        };
        patches = attrs.patches ++ [
          (pkgs.fetchurl {
            url = "https://github.com/Alinto/sogo/compare/SOGo-5.7.1...714acfc838ab26fc9de52cbf382faa410708ab4c.patch";
            sha256 = "sha256-KPvL4mQhzCNkdkqy7XbanI074e/MBlJFdZ/8+r3Qe/4=";
          })
        ];
      });
    })
  ];

  services.sogo = {
    enable = true;
    language = "ChineseChina";
    timezone = config.time.timeZone;
    configReplaces = {
      __LDAP_BINDPW__ = secrets.bindDnPw.path;
    };
  };
  services.sogo.extraConfig = ''
    /* General Preferences */
    WOWorkersCount = 8;
    SOGoMemcachedHost = "/run/memcached/memcached.sock";
    SOGoMailDomain = "sogo.local";
    SOGoCalendarDefaultRoles = (
      PublicViewer,
      ConfidentialDAndTViewer
    );
    SOGoEnablePublicAccess = YES;
    SOGoSupportedLanguages = (
      "ChineseChina",
      "ChineseTaiwan",
      "English",
      "Japanese"
    );
    /* Authentication using LDAP */
    SOGoUserSources = (
      {
        id = public;
        displayName = "Shared Addresses";
        type = ldap;
        CNFieldName = cn;
        IDFieldName = cn;
        UIDFieldName = mail;
        MailFieldNames = ( "mail" );
        baseDN = "ou=domains,dc=eh5,dc=me";
        filter = "objectClass='PostfixBookMailAccount'";
        bindDN = "cn=admin,dc=eh5,dc=me";
        bindPassword = "__LDAP_BINDPW__";
        bindFields = ( "mail" );
        hostname = "ldap://127.0.0.1:389";
        canAuthenticate = YES;
        isAddressBook = YES;
        listRequiresDot = NO;
        GroupObjectClasses = ( "groupOfNames" );
      }
    );
    /* Database Configuration */
    SOGoProfileURL = "postgresql://sogo@/sogo/sogo_user_profile";
    OCSFolderInfoURL = "postgresql://sogo@/sogo/sogo_folder_info";
    OCSSessionsFolderURL = "postgresql://sogo@/sogo/sogo_sessions_folder";
    OCSEMailAlarmsFolderURL = "postgresql://sogo@/sogo/sogo_alarms_folder";
    OCSStoreURL = "postgresql://sogo@/sogo/sogo_store";
    OCSAclURL = "postgresql://sogo@/sogo/sogo_acl";
    OCSCacheFolderURL = "postgresql://sogo@/sogo/sogo_cache_folder";
    /* SMTP Server Configuration */
    SOGoMailingMechanism = "smtp";
    SOGoSMTPServer = "smtps://mx.eh5.me:465";
    SOGoSMTPAuthenticationType = "PLAIN";
    /* IMAP Server Configuration */
    SOGoIMAPServer = "imaps://mx.eh5.me:993";
    SOGoIMAPAclConformsToIMAPExt = YES;
    /* Web Interface Configuration */
    SOGoZipPath = "${pkgs.zip}/bin/zip";
    SOGoFirstDayOfWeek = 1;
    SOGoShortDateFormat = "%y-%m-%d";
    SOGoLongDateFormat = "%Y年%m月%d日";
    SOGoGravatarEnabled = YES;
    SOGoMailComposeMessageType = text;
    SOGoEnableEMailAlarms = YES;
    /* Microsoft Enterprise ActiveSync */
    SOGoEASSearchInBody = YES;
  '';
  systemd.services.sogo =
    let
      services = [ "openldap.service" "dovecot2.service" "postgresql.service" "memcached.service" ];
    in
    {
      wants = lib.mkForce services;
      after = lib.mkForce services;
    };

  systemd.services.postgresql.postStart = lib.mkAfter ''
    createuser sogo || true
    createdb -O sogo sogo || true
  '';

  services.memcached = {
    enable = true;
    enableUnixSocket = true;
    extraOptions = [ "-a" "0770" ];
  };
  users.users.sogo.extraGroups = [ "memcached" ];

  services.caddy.virtualHosts = {
    "mail.eh5.me".extraConfig = lib.mkAfter ''
      route {
        redir / /SOGo
        rewrite /.well-known/caldav* /SOGo/dav
        rewrite /.well-known/carddav* /SOGo/dav
        handle_path /SOGo.woa/WebServerResources/* {
          root * ${pkgs.sogo}/lib/GNUstep/SOGo/WebServerResources/
          file_server
        }
        handle_path /SOGo/WebServerResources/* {
          root * ${pkgs.sogo}/lib/GNUstep/SOGo/WebServerResources/
          file_server
        }
        reverse_proxy /SOGo* http://127.0.0.1:20000 {
          header_up X-Real-IP {remote_host}
          header_up x-webobjects-server-port  {hostport}
          header_up x-webobjects-server-name  {host}
          header_up x-webobjects-server-url   {scheme}://{host}
          header_up x-webobjects-server-protocol HTTP/1.0
          header_up -x-webobjects-remote-user
        }
        reverse_proxy /Microsoft-Server-ActiveSync* http://127.0.0.1:20000 {
          header_up X-Real-IP {remote_host}
          rewrite /SOGo{path}
        }
      }
    '';
  };
}
