{ config, pkgs, lib, ... }:
let
  cfg = config.mail;
  dovecot2Cfg = config.services.dovecot2;
  postfixCfg = config.services.postfix;
  secrets = config.sops.secrets;
  stateDir = "/var/lib/dovecot";
  pipeBin = pkgs.stdenv.mkDerivation {
    name = "pipe_bin";
    src = ./files/pipe_bin;
    buildInputs = with pkgs; [ makeWrapper coreutils bash rspamd ];
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
    modules = [ pkgs.dovecot_pigeonhole ];
    mailPlugins.globally.enable = [ "zlib" "mail_crypt" "listescape" "notify" "mail_log" ];
    mailPlugins.perProtocol.imap.enable = [ "imap_zlib" "imap_sieve" ];
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
    };
    sieveScripts = {
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
  };

  services.dovecot2.extraConfig = ''
    mail_home = "${cfg.maildirRoot}/%d/%n"
    mail_location = maildir:~/Maildir
    ssl_prefer_server_ciphers = yes

    recipient_delimiter = +
    lmtp_save_to_detail_mailbox = no

    auth_mechanisms = plain login
    auth_master_user_separator = *

    lda_mailbox_autosubscribe = yes
    lda_mailbox_autocreate = yes

    haproxy_trusted_networks = <${secrets.trustedNetworks.path}

    plugin {
      listescape_char = "\\"

      mail_crypt_global_private_key = <${secrets.mailCryptPrivKey.path}
      mail_crypt_global_public_key = <${secrets.mailCryptPubKey.path}
      mail_crypt_save_version = 2

      zlib_save = lz4
    }

    passdb {
      driver = passwd-file
      args = ${secrets.passwdFile.path}
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

    plugin {
      sieve_plugins = sieve_imapsieve sieve_extprograms
      sieve_default_name = default

      # From elsewhere to Spam folder
      imapsieve_mailbox1_name = Junk
      imapsieve_mailbox1_causes = COPY
      imapsieve_mailbox1_before = file:${stateDir}/imap_sieve/report-spam.sieve

      # From Spam folder to elsewhere
      imapsieve_mailbox2_name = *
      imapsieve_mailbox2_from = Junk
      imapsieve_mailbox2_causes = COPY
      imapsieve_mailbox2_before = file:${stateDir}/imap_sieve/report-ham.sieve

      sieve_pipe_bin_dir = ${pipeBin}/pipe/bin

      sieve_global_extensions = +vnd.dovecot.pipe +vnd.dovecot.environment
    }
  '';

  systemd.services.dovecot2.preStart = ''
    rm -rf '${stateDir}/imap_sieve'
    mkdir '${stateDir}/imap_sieve'
    cp -p "${./files/imap_sieve}"/*.sieve '${stateDir}/imap_sieve/'
    for k in "${stateDir}/imap_sieve"/*.sieve ; do
      ${pkgs.dovecot_pigeonhole}/bin/sievec "$k"
    done
    chown -R '${dovecot2Cfg.mailUser}:${dovecot2Cfg.mailGroup}' '${stateDir}/imap_sieve'
  '';
}
