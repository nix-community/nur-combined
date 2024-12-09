{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.mail;
  secrets = config.sops.secrets;
  certName = "eh5.me";
  acmeCert = config.security.acme.certs.${certName};
in
{
  users.users.stalwart-mail = {
    isSystemUser = true;
    home = "/var/lib/stalwart-mail";
    group = acmeCert.group;
  };

  services.stalwart-mail.enable = false;
  services.stalwart-mail.settings = {
    include.files = [ secrets."stalwart.toml".path ];

    global.tracing.level = "trace";
    resolver.public-suffix = [
      "https://publicsuffix.org/list/public_suffix_list.dat"
    ];

    server = {
      hostname = cfg.fqdn;
      tls = {
        certificate = "default";
        ignore-client-order = true;
      };
      socket = {
        nodelay = true;
        reuse-addr = true;
      };
    };
    server.listener = {
      lmtp = {
        protocol = "lmtp";
        bind = "127.0.0.1:11200";
      };
      jmap = {
        protocol = "jmap";
        bind = "127.0.0.1:18080";
        url = "https://mail.eh5.me/jmap";
      };
      imaps = {
        protocol = "imap";
        bind = "[::]:1993";
        tls.enable = true;
        tls.implicit = true;
      };
    };

    session = {
      rcpt = {
        directory = "default";
        relay = [
          {
            "if" = "authenticated-as";
            ne = "";
            "then" = true;
          }
          { "else" = false; }
        ];
      };
    };

    queue = {
      outbound = {
        next-hop = [
          {
            "if" = "rcpt-domain";
            in-list = "default/domains";
            "then" = "local";
          }
          { "else" = "relay"; }
        ];
        tls = {
          mta-sts = "disable";
          dane = "disable";
        };
      };
    };

    remote.relay = {
      protocol = "smtp";
      address = "127.0.0.1";
      port = 25;
    };

    jmap = {
      directory = "default";
      http.headers = [
        "Access-Control-Allow-Origin: *"
        "Access-Control-Allow-Methods: POST, GET, HEAD, OPTIONS"
        "Access-Control-Allow-Headers: *"
      ];
    };

    management.directory = "default";

    directory.default = {
      type = "ldap";
      address = "ldap://127.0.0.1:389";
      base-dn = "ou=domains,dc=eh5,dc=me";
      bind = {
        dn = "cn=admin,dc=eh5,dc=me";
      };
      filter = {
        name = "(&(objectClass=PostfixBookMailAccount)(mail=?))";
        email = "(&(objectClass=PostfixBookMailAccount)(|(mail=?)(mailAlias=?)(mailList=?)))";
        verify = "(&(objectClass=PostfixBookMailAccount)(|(mail=*?*)(mailAlias=*?*)))";
        expand = "(&(objectClass=PostfixBookMailAccount)(mailList=?))";
        domains = "(&(objectClass=PostfixBookMailAccount)(|(mail=*@?)(mailAlias=*@?)))";
      };
      object-classes = {
        user = "PostfixBookMailAccount";
        group = "PostfixBookMailAccount";
      };
      attributes = {
        name = "mail";
        description = [
          "givenName"
          "sn"
        ];
        secret = "userPassword";
        groups = "mailGroupMember";
        email = "mail";
        email-alias = "mailAlias";
        quota = "mailQuota";
      };
    };

    certificate.default = {
      cert = "file://${cfg.certFile}";
      private-key = "file://${cfg.keyFile}";
    };
  };

  systemd.services.stalwart-mail = {
    serviceConfig = {
      StandardOutput = lib.mkForce "journal";
      StandardError = lib.mkForce "journal";
      SupplementaryGroups = [ acmeCert.group ];
    };
  };

  services.caddy.virtualHosts = {
    "mail.eh5.me".extraConfig = lib.mkAfter ''
      rewrite /.well-known/jmap /jmap/.well-known/jmap
      handle_path /jmap* {
        reverse_proxy http://127.0.0.1:18080
      }
    '';
  };
}
