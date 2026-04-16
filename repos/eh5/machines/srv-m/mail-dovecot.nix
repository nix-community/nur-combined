{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.mail;
  dovecot2Cfg = config.services.dovecot2.settings;
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
    package = pkgs.dovecot_2_4;
    createMailUser = false;
    enablePAM = false;
    sieve = {
      pipeBins = [
        "${pipeBin}/pipe/bin/sa-learn-spam.sh"
        "${pipeBin}/pipe/bin/sa-learn-ham.sh"
      ];
    };
  };

  services.dovecot2.settings = {
    dovecot_config_version = "2.4.3";
    dovecot_storage_version = "2.4.3";

    protocols = {
      lmtp = true;
      imap = true;
    };

    mail_uid = cfg.vmailUser;
    mail_gid = cfg.vmailGroup;

    mail_home = "${cfg.maildirRoot}/%{user | domain}/%{user | username}";
    mail_driver = "maildir";
    mail_path = "~/Maildir";

    "namespace inbox" = {
      inbox = true;
      separator = "/";

      "mailbox Trash" = {
        auto = "subscribe";
        special_use = "\\Trash";
      };
      "mailbox Archive" = {
        auto = "subscribe";
        special_use = "\\Archive";
      };
      "mailbox Sent" = {
        auto = "subscribe";
        special_use = "\\Sent";
      };
      "mailbox Drafts" = {
        auto = "subscribe";
        special_use = "\\Drafts";
      };
      "mailbox Junk" = {
        auto = "subscribe";
        special_use = "\\Junk";
      };
      "mailbox Spam" = {
        special_use = "\\Junk";
      };
    };

    mailbox_list_storage_escape_char = "\"\\\\\"";

    recipient_delimiter = "+";
    lmtp_save_to_detail_mailbox = "no";

    ssl_server_cert_file = cfg.certFile;
    ssl_server_key_file = cfg.keyFile;
    ssl_server_prefer_ciphers = "server";

    auth_master_user_separator = "*";
    auth_mechanisms = {
      plain = true;
      login = true;
    };

    haproxy_trusted_networks = "<${secrets.trustedNetworks.path}";

    ldap_uris = "ldap://localhost";
    ldap_auth_dn = "cn=admin,dc=eh5,dc=me";
    ldap_auth_dn_password = "<${secrets.bindDnPw.path}";
    ldap_base = "ou=domains,dc=eh5,dc=me";
    "passdb ldap" = {
      bind = true;
      filter = "(&(objectClass=PostfixBookMailAccount)(mail=%{user | lower}))";
      fields = {
        user = "%{ldap:mail}";
      };
    };

    "service auth" = {
      "unix_listener postfix-auth" = {
        mode = "0660";
        user = postfixCfg.user;
        group = postfixCfg.group;
      };
    };

    "service lmtp" = {
      "unix_listener postfix-lmtp" = {
        mode = "0660";
        user = postfixCfg.user;
        group = postfixCfg.group;
      };
    };

    imap_hibernate_timeout = "5s";
    "service imap" = {
      "unix_listener imap-master" = {
        user = "$SET:default_internal_user";
      };
    };

    "service imap-login" = {
      "inet_listener imap" = {
        port = 143;
      };
      "inet_listener imaps" = {
        port = 993;
        ssl = true;
      };
      "inet_listener imap_haproxy" = {
        port = 10143;
        haproxy = true;
      };
      "inet_listener imaps_haproxy" = {
        port = 10993;
        ssl = true;
        haproxy = true;
      };
    };

    "protocol lmtp" = {
      mail_plugins = {
        sieve = true;
      };
    };

    "protocol imap" = {
      mail_max_userip_connections = 100;
      mail_plugins = {
        imap_acl = true;
        imap_sieve = true;
      };
    };

    mail_plugins = {
      acl = true;
      mail_compress = true;
      mail_crypt = true;
      notify = true;
      mail_log = true;
      # fts = true;
      # nix dovecot 2.4 not compiled with fts_flatcurve, disable for now
      # fts_flatcurve = true;
    };

    acl_driver = "vfile";
    acl_globals_only = true;
    acl_sharing_map = {
      "dict file" = {
        path = "${cfg.maildirRoot}/shared-mailboxes.db";
      };
    };

    "crypt_global_private_key main" = {
      crypt_private_key_file = secrets."ecprivkey.pem".path;
    };
    crypt_global_public_key_file = secrets."ecpubkey.pem".path;

    mail_compress_write_method = "lz4";

    # fts_driver = "flatcurve";
    # fts_autoindex = true;

    # language_filters = "normalizer-icu snowball stopwords";
    # "language en" = {
    #   default = true;
    #   language_filters = "lowercase snowball english-possessive stopwords";
    # };

    sieve_plugins = {
      sieve_imapsieve = true;
      sieve_extprograms = true;
    };
    sieve_extensions = {
      "variables" = true;
      "fileinto" = true;
      "envelope" = true;
      "subaddress" = true;
      "mailbox" = true;
      "duplicate" = true;
    };
    sieve_global_extensions = {
      "vnd.dovecot.environment" = true;
    };

    "sieve_script after" = {
      path = builtins.toFile "spam.sieve" ''
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

    "imapsieve_from Junk" = {
      "sieve_script ham" = {
        type = "before";
        cause = "copy";
        path = ./files/imap_sieve/report-ham.sieve;
      };
    };
    "mailbox Junk" = {
      "sieve_script spam" = {
        type = "before";
        cause = "copy";
        path = ./files/imap_sieve/report-spam.sieve;
      };
    };
  };

  systemd.services.dovecot = {
    requires = [ "openldap.service" ];
    after = [ "openldap.service" ];
  };

  environment.systemPackages = with pkgs; [
    dovecot_pigeonhole_2_4
  ];
}
