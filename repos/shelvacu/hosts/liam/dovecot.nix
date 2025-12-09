{
  config,
  lib,
  vaculib,
  ...
}:
{
  networking.firewall.allowedTCPPorts = [ 993 ];
  systemd.tmpfiles.settings.whatever."/var/lib/mail".d = {
    user = config.services.dovecot2.mailUser;
    group = config.services.dovecot2.mailGroup;
    mode = vaculib.accessModeStr { user = "all"; };
  };
  systemd.tmpfiles.settings.whatever."/var/lib/postfix/queue/private".d = {
    user = config.services.postfix.user;
    group = config.services.postfix.group;
    mode = vaculib.accessModeStr { user = "all"; };
  };
  vacu.acmeCertDependencies."liam.dis8.net" = [ "dovecot2.service" ];
  services.dovecot2 = {
    enable = true;
    sslServerKey = config.security.acme.certs."liam.dis8.net".directory + "/key.pem";
    sslServerCert = config.security.acme.certs."liam.dis8.net".directory + "/full.pem";
    enablePAM = false;
    protocols = lib.mkForce [
      "imap"
      "lmtp"
      "sieve"
    ];
    mailUser = "vmail";
    mailGroup = "vmail";
    createMailUser = true;
    mailLocation = "mdbox:~/mail";
    extraConfig = ''
      mail_home = /var/lib/mail/%n
      mail_max_userip_connections = 100

      # mail_debug = yes
      mail_plugins = $mail_plugins notify mail_log

      service auth {
        unix_listener /var/lib/postfix/queue/private/dovecot-auth {
          group = ${config.services.postfix.group}
          mode = ${
            vaculib.accessMode {
              user = {
                read = true;
                write = true;
              };
              group = {
                read = true;
                write = true;
              };
            }
          }
          user = ${config.services.postfix.user}
        }
      }

      service lmtp {
        unix_listener /var/lib/postfix/queue/private/dovecot-lmtp {
          group = ${config.services.postfix.group}
          mode = ${
            vaculib.accessMode {
              user = {
                read = true;
                write = true;
              };
              group = {
                read = true;
                write = true;
              };
            }
          }
          user = ${config.services.postfix.user}
        }
      }

      protocol lmtp {
        postmaster_address = postmaster@shelvacu.com
        mail_plugins = $mail_plugins sieve
      }

      protocol imaps {
        disable_plaintext_auth = yes
        ssl = required
        ssl_min_protocol = TLSv1.2
        ssl_cipher_list = ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305
        ssl_prefer_server_ciphers = no
      }

      protocol imap {
        disable_plaintext_auth = yes
        ssl = required
        ssl_min_protocol = TLSv1.2
        ssl_cipher_list = ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305
        ssl_prefer_server_ciphers = no
      }

      service imap-login {
        inet_listener imap {
          # this disables non-SSL IMAP, including STARTTLS
          port = 0
        }
        inet_listener imaps {
          port = 993
          ssl = yes
        }
      }

      userdb {
        driver = passwd-file
        args = username_format=%n ${config.sops.secrets."dovecot-passwd".path}
        override_fields = uid=${config.services.dovecot2.mailUser} gid=${config.services.dovecot2.mailGroup} user=%n
      }

      passdb {
        driver = passwd-file
        args = username_format=%n ${config.sops.secrets."dovecot-passwd".path}
        override_fields = user=%n
      }

      namespace {
        separator = .
        inbox = yes
        
        mailbox MagicRefilter {
          auto = create
        }
      }

      plugin {
        # sieve_trace_debug = yes
        mail_log_events = delete undelete expunge save copy mailbox_create mailbox_delete mailbox_rename flag_change
        mail_log_fields = uid box msgid size from
      }
    '';
  };
}
