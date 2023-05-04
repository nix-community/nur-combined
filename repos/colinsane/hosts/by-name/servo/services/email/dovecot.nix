# dovecot config options: <https://doc.dovecot.org/configuration_manual/>
#
# sieve docs:
# - sieve language examples: <https://doc.dovecot.org/configuration_manual/sieve/examples/>
# - sieve protocol/language: <https://proton.me/support/sieve-advanced-custom-filters>

{ config, lib, pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [
    # exposed over non-vpn imap.uninsane.org
    143  # IMAP
    993  # IMAPS
  ];

  # exists only to manage certs for dovecot
  services.nginx.virtualHosts."imap.uninsane.org" = {
    enableACME = true;
  };

  sane.services.trust-dns.zones."uninsane.org".inet = {
    CNAME."imap" = "native";
  };

  sops.secrets."dovecot_passwd" = {
    owner = config.users.users.dovecot2.name;
    # TODO: debug why mail can't be sent without this being world-readable
    mode = "0444";
  };

  # inspired by https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/
  services.dovecot2.enable = true;
  # services.dovecot2.enableLmtp = true;
  services.dovecot2.sslServerCert = "/var/lib/acme/imap.uninsane.org/fullchain.pem";
  services.dovecot2.sslServerKey = "/var/lib/acme/imap.uninsane.org/key.pem";
  services.dovecot2.enablePAM = false;

  # sieve scripts require me to set a user for... idk why?
  services.dovecot2.mailUser = "colin";
  services.dovecot2.mailGroup = "users";
  users.users.colin.isSystemUser = lib.mkForce false;

  services.dovecot2.extraConfig =
  let
    passwdFile = config.sops.secrets.dovecot_passwd.path;
  in
    ''
    passdb {
      driver = passwd-file
      args = ${passwdFile}
    }
    userdb {
      driver = passwd-file
      args = ${passwdFile}
    }

    # allow postfix to query our auth db
    service auth {
      unix_listener auth {
        mode = 0660
        user = postfix
        group = postfix
      }
    }
    auth_mechanisms = plain login

    # accept incoming messaging from postfix
    # service lmtp {
    #   unix_listener dovecot-lmtp {
    #     mode = 0600
    #     user = postfix
    #     group = postfix
    #   }
    # }

    # plugin {
    #   sieve_plugins = sieve_imapsieve
    # }

    mail_debug = yes
    auth_debug = yes
    # verbose_ssl = yes
  '';

  services.dovecot2.mailboxes = {
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
    Drafts = { specialUse = "Drafts"; auto = "create"; };
    Sent = { specialUse = "Sent"; auto = "create"; };
    Trash = { specialUse = "Trash"; auto = "create"; };
    Junk = { specialUse = "Junk"; auto = "create"; };
  };

  services.dovecot2.mailPlugins = {
    perProtocol = {
      # imap.enable = [
      #   "imap_sieve"
      # ];
      lda.enable = [
        "sieve"
      ];
      # lmtp.enable = [
      #   "sieve"
      # ];
    };
  };
  services.dovecot2.modules = [
    pkgs.dovecot_pigeonhole  # enables sieve execution (?)
  ];
  services.dovecot2.sieveScripts = {
    # if any messages fail to pass (or lack) DKIM, move them to Junk
    # XXX the key name ("after") is only used to order sieve execution/ordering
    after = builtins.toFile "ensuredkim.sieve" ''
      require "fileinto";

      if not header :contains "Authentication-Results" "dkim=pass" {
        fileinto "Junk";
        stop;
      }
    '';
  };
}
