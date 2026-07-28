{
  config,
  pkgs,
  vaculib,
  ...
}:
{
  networking.firewall.allowedTCPPorts = [ 993 ];
  systemd.tmpfiles.settings.whatever."/var/lib/mail".d = {
    user = config.services.dovecot2.settings.mail_uid;
    group = config.services.dovecot2.settings.mail_gid;
    mode = vaculib.accessModeStr { user = "all"; };
  };
  systemd.tmpfiles.settings.whatever."/var/lib/postfix/queue/private".d = {
    user = config.services.postfix.user;
    group = config.services.postfix.group;
    mode = vaculib.accessModeStr { user = "all"; };
  };
  vacu.acmeCertDependencies."liam.dis8.net" = [ "dovecot.service" ];
  services.dovecot2 = {
    enable = true;
    package = pkgs.dovecot_2_3;
    enablePAM = false;
    createMailUser = true;
    settings = {
      ssl_key = "<" + config.security.acme.certs."liam.dis8.net".directory + "/key.pem";
      ssl_cert = "<" + config.security.acme.certs."liam.dis8.net".directory + "/full.pem";
      protocols = "imap lmtp sieve";
      mail_location = "mdbox:~/mail";
      mail_uid = "vmail";
      mail_gid = "vmail";
      mail_home = "/var/lib/mail/%n";
      mail_max_userip_connections = 100;
      # mail_debug = true;
      mail_plugins = "$mail_plugins notify mail_log";
      service = [
        {
          _section.name = "auth";
          "unix_listener /var/lib/postfix/queue/private/dovecot-auth" = {
            inherit (config.services.postfix) user group;
            mode = vaculib.accessModeStr {
              user = {
                read = true;
                write = true;
              };
              group = {
                read = true;
                write = true;
              };
            };
          };
        }
        {
          _section.name = "lmtp";
          "unix_listener /var/lib/postfix/queue/private/dovecot-lmtp" = {
            inherit (config.services.postfix) user group;
            mode = vaculib.accessModeStr {
              user = {
                read = true;
                write = true;
              };
              group = {
                read = true;
                write = true;
              };
            };
          };
        }
        {
          _section.name = "imap-login";
          # this disables non-SSL IMAP, including STARTTLS
          "inet_listener imap".port = 0;
          "inet_listener imaps" = {
            port = 993;
            ssl = true;
          };
        }
      ];

      "protocol lmtp" = {
        postmaster_address = "postmaster@shelvacu.com";
        mail_plugins = "$mail_plugins sieve";
      };

      "protocol imaps" = {
        disable_plaintext_auth = true;
        ssl = "required";
        ssl_min_protocol = "TLSv1.2";
        ssl_cipher_list = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305";
        ssl_prefer_server_ciphers = false;
      };

      "protocol imap" = {
        disable_plaintext_auth = true;
        ssl = "required";
        ssl_min_protocol = "TLSv1.2";
        ssl_cipher_list = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305";
        ssl_prefer_server_ciphers = false;
      };

      userdb = {
        driver = "passwd-file";
        args = "username_format=%n ${config.sops.secrets."dovecot-passwd".path}";
        override_fields = "uid=${config.services.dovecot2.settings.mail_uid} gid=${config.services.dovecot2.settings.mail_gid} user=%n";
      };

      passdb = {
        driver = "passwd-file";
        args = "username_format=%n ${config.sops.secrets."dovecot-passwd".path}";
        override_fields = "user=%n";
      };

      namespace = {
        separator = ".";
        inbox = true;
        "mailbox MagicRefilter".auto = "create";
      };

      plugin = {
        mail_log_events = "delete undelete expunge save copy mailbox_create mailbox_delete mailbox_rename flag_change";
        mail_log_fields = "uid box msgid size from";
      };
    };
  };
}
