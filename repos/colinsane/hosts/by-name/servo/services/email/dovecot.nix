# dovecot config options: <https://doc.dovecot.org/latest/core/summaries/settings.html#all-dovecot-settings>
#
# sieve docs:
# - sieve language examples: <https://doc.dovecot.org/configuration_manual/sieve/examples/>
# - sieve protocol/language: <https://proton.me/support/sieve-advanced-custom-filters>
#
# postfix + dovecot lmtp: <https://doc.dovecot.org/2.4.3/howto/lmtp/postfix.html#postfix-and-dovecot-lmtp>

{ config, lib, pkgs, ... }:
{
  sane.ports.ports."143" = {
    protocol = [ "tcp" ];
    visibleTo.doof = true;
    visibleTo.lan = true;
    description = "colin-imap-imap.uninsane.org";
  };
  sane.ports.ports."993" = {
    protocol = [ "tcp" ];
    visibleTo.doof = true;
    visibleTo.lan = true;
    description = "colin-imaps-imap.uninsane.org";
  };

  # exists only to manage certs for dovecot
  services.nginx.virtualHosts."imap.uninsane.org" = {
    enableACME = true;
  };

  sane.dns.zones."uninsane.org".inet = {
    CNAME."imap" = "native";
  };

  sops.secrets."dovecot_passwd" = {
    owner = config.users.users.dovecot2.name;
    # TODO: debug why mail can't be sent without this being world-readable
    mode = "0444";
  };

  # inspired by https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/
  services.dovecot2.enable = true;
  # XXX 2026-04-16: package only defaults to latest dovecot based on system.stateVersion, but actually the module does not work OOTB with old dovecot (dovecot2_3).
  services.dovecot2.package = pkgs.dovecot;
  # services.dovecot2.enableLmtp = true;
  services.dovecot2.enablePAM = false;

  services.dovecot2.settings =
  let
    passwdFile = config.sops.secrets.dovecot_passwd.path;
  in {
    dovecot_config_version = config.services.dovecot2.package.version;  #< .... wow. this is a fragile module :|
    dovecot_storage_version = config.services.dovecot2.package.version;

    ssl_server_cert_file = "/var/lib/acme/imap.uninsane.org/fullchain.pem";
    ssl_server_key_file = "/var/lib/acme/imap.uninsane.org/key.pem";
    "passdb pam" = {
      driver = "passwd-file";
      passwd_file_path = passwdFile;
    };
    "userdb passwd" = {
      driver = "passwd-file";
      passwd_file_path = passwdFile;
    };

    # allow postfix to query our auth db
    "service auth" = {
      "unix_listener auth" = {
        mode = "0666";
        # user = "postfix";
        # group = "postfix";
      };
    };
    auth_mechanisms = [
      "plain"
      "login"
    ];

    # accept incoming messaging from postfix
    "service lmtp" = {
      "unix_listener dovecot-lmtp" = {
        mode = "0666";
        # user = "postfix";
        # group = "postfix";
      };
      # "unix_listener /var/spool/postfix/private/dovecot-lmtp" = {
      #   mode = "0660";
      #   user = "postfix";
      #   group = "postfix";
      # };
    };

    protocols.imap = true;
    # protocols.lda = true;
    protocols.lmtp = true;

    # plugin {
    #   sieve_plugins = sieve_imapsieve
    # }

    mail_debug = true;
    auth_debug = true;
    # verbose_ssl = true;

    # special-purpose mailboxes: "All" "Archive" "Drafts" "Flagged" "Junk" "Sent" "Trash"
    # RFC6154 describes these special mailboxes: https://www.ietf.org/rfc/rfc6154.html
    # how these boxes are treated is 100% up to the client and server to decide.
    # client behavior:
    # iOS
    #   - Drafts: ?
    #   - Sent: works
    #   - Trash: works
    #   - Junk: works ("mark" -> "move to Junk")
    # aerc
    #   - Drafts: works
    #   - Sent: works
    #   - Trash: no; deleted messages are actually deleted
    #       use `:move trash` instead
    #   - Junk: ?
    # Sent mailbox: all sent messages are copied to it. unclear if this happens server-side or client-side.
    "namespace inbox" = {
      inbox = true;
      "mailbox Drafts" = {
        auto = "create";
        special_use = "\\Drafts";
      };
      "mailbox Sent" = {
        auto = "create";
        special_use = "\\Sent";
      };
      "mailbox Trash" = {
        auto = "create";
        special_use = "\\Trash";
      };
      "mailbox Junk" = {
        auto = "create";
        special_use = "\\Junk";
      };
    };

    # "protocol imap" = {
    #   mail_plugins = [ "imap_sieve" ];
    # };
    "protocol lda" = {
      mail_plugins = [ "sieve" ];
    };
    "protocol lmtp" = {
      postmaster_address = "postmaster@uninsane.org";
      mail_plugins = [ "sieve" ];
    };

    # mail_path = "/var/mail/%{user | username}";
    # mail_driver = "Maildir";

    sieve_extensions = [ "fileinto" ];
    # if any messages fail to pass (or lack) DKIM, move them to Junk
    # XXX the key name ("after") is only used to order sieve execution/ordering
    "sieve_script after" = {
      path = builtins.toFile "ensuredkim.sieve" ''
        require "fileinto";

        if not header :contains "Authentication-Results" "dkim=pass" {
          fileinto "Junk";
          stop;
        }
      '';
    };

    # sieve scripts require me to set a user for... idk why?
    mail_uid = "colin";
    mail_gid = "users";
  };

  # i think dovecot requires `mail_uid` not be a "system user"?
  users.users.colin.isSystemUser = lib.mkForce false;

  environment.systemPackages = [
    # XXX(2025-03-16): dovecot loads modules from /run/current-system/sw/lib/dovecot/modules
    # see: <https://github.com/NixOS/nixpkgs/pull/387642>
    config.services.dovecot2.package.dovecot_pigeonhole  # enables sieve execution (?)
  ];

  systemd.services.dovecot.serviceConfig.RestartSec = lib.mkForce "15s";  # nixos defaults this to 1s
}
