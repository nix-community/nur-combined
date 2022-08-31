{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.mail;

  inherit (lib.my) mkMailAddress;

  mkConfig = { domain, address, passName, aliases ? [ ], primary ? false }: {
    realName = lib.mkDefault "Bruno BELANYI";
    userName = lib.mkDefault (mkMailAddress address domain);
    passwordCommand =
      lib.mkDefault [ "${pkgs.ambroisie.bw-pass}/bin/bw-pass" "Mail" passName ];

    address = mkMailAddress address domain;
    aliases = builtins.map (lib.flip mkMailAddress domain) aliases;

    inherit primary;

    himalaya = {
      enable = cfg.himalaya.enable;
    };

    msmtp = {
      enable = cfg.msmtp.enable;
    };
  };

  migaduConfig = {
    imap = {
      host = "imap.migadu.com";
      port = 993;
      tls = {
        enable = true;
      };
    };
    smtp = {
      host = "smtp.migadu.com";
      port = 465;
      tls = {
        enable = true;
      };
    };
  };

  gmailConfig = {
    flavor = "gmail.com";
    folders = {
      drafts = "[Gmail]/Drafts";
      sent = "[Gmail]/Sent Mail";
      trash = "[Gmail]/Trash";
    };
  };

  office365Config = {
    flavor = "outlook.office365.com";
  };
in
{
  config.accounts.email.accounts = {
    personal = lib.mkMerge [
      # Common configuraton
      (mkConfig {
        domain = "belanyi.fr";
        address = "bruno";
        passName = "Migadu";
        aliases = [ "admin" "postmaster" ];
        primary = true; # This is my primary email
      })
      migaduConfig
    ];

    gmail = lib.mkMerge [
      # Common configuraton
      (mkConfig {
        domain = "gmail.com";
        address = "brunobelanyi";
        passName = "GMail";
      })
      gmailConfig
    ];

    epita = lib.mkMerge [
      # Common configuration
      (mkConfig {
        domain = "epita.fr";
        address = "bruno.belanyi";
        passName = "EPITA";
      })
      office365Config
    ];
  };
}
