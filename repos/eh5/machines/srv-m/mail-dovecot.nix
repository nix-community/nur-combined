{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.mail;
  dovecot2Cfg = config.services.dovecot2;
  postfixCfg = config.services.postfix;
  secrets = config.sops.secrets;
  stateDir = "/var/lib/dovecot";
  pipeBin = pkgs.stdenv.mkDerivation {
    name = "pipe_bin";
    src = ./files/pipe_bin;
    buildInputs = with pkgs; [
      makeWrapper
      coreutils
      bash
      rspamd
    ];
    buildCommand = ''
      mkdir -p $out/pipe/bin
      cp $src/* $out/pipe/bin/
      chmod a+x $out/pipe/bin/*
      patchShebangs $out/pipe/bin

      for file in $out/pipe/bin/*; do
        wrapProgram $file \
          --set PATH "${pkgs.coreutils}/bin:${pkgs.rspamd}/bin"
      done
    '';
  };
in
{
  services.dovecot2 = {
    enable = true;
    enableLmtp = true;
    enableImap = true;
    enablePAM = false;
    mailUser = cfg.vmailUser;
    mailGroup = cfg.vmailGroup;
    mailLocation = "maildir:~/Maildir";
    sslServerCert = cfg.certFile;
    sslServerKey = cfg.keyFile;
    mailPlugins.globally.enable = [
      "acl"
      "zlib"
      "mail_crypt"
      "listescape"
      "notify"
      "mail_log"
      "fts"
      "fts_flatcurve"
    ];
    mailPlugins.perProtocol.imap.enable = [
      "imap_acl"
      "imap_zlib"
      "imap_sieve"
    ];
    mailPlugins.perProtocol.lmtp.enable = [ "sieve" ];
    mailboxes = {
      Trash = {
        auto = "subscribe";
        specialUse = "Trash";
      };
      Archive = {
        auto = "subscribe";
        specialUse = "Archive";
      };
      Sent = {
        auto = "subscribe";
        specialUse = "Sent";
      };
      Drafts = {
        auto = "subscribe";
        specialUse = "Drafts";
      };
      Junk = {
        auto = "subscribe";
        specialUse = "Junk";
      };
      Spam.specialUse = "Junk";
      Templates.auto = "create";
    };
    sieve = {
      pipeBins = [
        "${pipeBin}/pipe/bin/sa-learn-spam.sh"
        "${pipeBin}/pipe/bin/sa-learn-ham.sh"
      ];
      extensions = [
        "variables"
        "fileinto"
        "envelope"
        "subaddress"
        "mailbox"
        "duplicate"
      ];
      globalExtensions = [
        "vnd.dovecot.environment"
      ];
    };
    sieve.scripts = {
      after = builtins.toFile "spam.sieve" ''
        require ["variables", "fileinto", "envelope", "subaddress", "mailbox", "duplicate"];

        if header :is "X-Spam" "Yes" {
            fileinto "Junk";
            stop;
        }

        # https://doc.dovecot.org/configuration_manual/sieve/examples/#emulating-lmtp-save-to-detail-mailbox-yes
        #
        if envelope :matches :detail "to" "*"{
          set :lower :upperfirst "tag" "''${1}";
          fileinto :create "INBOX/''${tag}";
        }

        if duplicate {
          discard;
          stop;
        }
      '';
    };
    imapsieve.mailbox = [
      {
        name = "Junk";
        causes = [ "COPY" ];
        before = ./files/imap_sieve/report-spam.sieve;
      }
      {
        name = "*";
        from = "JUNK";
        causes = [ "COPY" ];
        before = ./files/imap_sieve/report-ham.sieve;
      }
    ];
  };

  services.dovecot2.extraConfig = ''
    mail_home = "${cfg.maildirRoot}/%d/%n"
    mail_location = maildir:~/Maildir
    mail_temp_dir = /dev/shm/
    ssl_prefer_server_ciphers = yes

    imap_hibernate_timeout = 5s

    recipient_delimiter = +
    lmtp_save_to_detail_mailbox = no

    auth_mechanisms = plain login
    auth_master_user_separator = *

    lda_mailbox_autosubscribe = yes
    lda_mailbox_autocreate = yes

    haproxy_trusted_networks = <${secrets.trustedNetworks.path}

    plugin {
      acl = vfile
      acl_shared_dict = file:/var/vmail/shared-mailboxes.db

      listescape_char = "\\"

      mail_crypt_global_private_key = <${secrets."ecprivkey.pem".path}
      mail_crypt_global_public_key = <${secrets."ecpubkey.pem".path}
      mail_crypt_save_version = 2

      zlib_save = lz4

      fts = flatcurve
      fts_autoindex = yes
      fts_enforced = body
      fts_filters = lowercase stopwords snowball
      fts_tokenizers = generic email-address
      # sadly they don't have Chinese support,
      # see https://doc.dovecot.org/settings/plugin/fts-plugin/#fts-languages
      fts_languages = en
    }

    passdb {
      driver = ldap
      args = ${secrets.passdbLdap.path}
    }

    userdb {
      driver = static
      args = uid=${cfg.vmailUser} gid=${cfg.vmailGroup}
    }

    service auth {
      unix_listener postfix-auth {
        mode = 0660
        user = ${postfixCfg.user}
        group = ${postfixCfg.group}
      }
    }

    service lmtp {
      unix_listener postfix-lmtp {
        mode = 0600
        user = ${postfixCfg.user}
        group = ${postfixCfg.group}
      }
    }

    service imap {
      unix_listener imap-master {
        user = $default_internal_user
      }
    }

    service imap-login {
      inet_listener imap {
        port = 143
      }
      inet_listener imaps {
        port = 993
        ssl = yes
      }
      inet_listener imap_haproxy {
        port = 10143
        haproxy = yes
      }
      inet_listener imaps_haproxy {
        port = 10993
        ssl = yes
        haproxy = yes
      }
    }

    protocol imap {
      mail_max_userip_connections = 100
    }

    namespace inbox {
      separator = /
      inbox = yes
    }
  '';

  systemd.services.dovecot2 = {
    requires = [ "openldap.service" ];
    after = [ "openldap.service" ];
  };

  environment.systemPackages = with pkgs; [
    dovecot_pigeonhole
    dovecot-fts-flatcurve
  ];

  # nixpkgs.overlays = [
  #   (
  #     final: prev: {
  #       dovecot_pigeonhole = prev.dovecot_pigeonhole.overrideAttrs (_: attrs: {
  #         buildInputs = attrs.buildInputs ++ [ pkgs.openldap pkgs.cyrus_sasl ];
  #         configureFlags = attrs.configureFlags ++ [ "--with-ldap=yes" ];
  #       });
  #     }
  #   )
  # ];
}
