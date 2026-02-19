{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.mail;

  inherit (lib.my) mkMailAddress;

  mkConfig = { domain, address, passName, aliases ? [ ], primary ? false }: {
    realName = lib.mkDefault "Bruno BELANYI";
    userName = lib.mkDefault (mkMailAddress address domain);
    passwordCommand =
      lib.mkDefault [ (lib.getExe pkgs.ambroisie.rbw-pass) "Mail" passName ];

    address = mkMailAddress address domain;
    aliases = builtins.map (lib.flip mkMailAddress domain) aliases;

    inherit primary;

    himalaya = {
      enable = cfg.himalaya.enable;
      # FIXME: try to actually configure it at some point
    };

    msmtp = {
      enable = cfg.msmtp.enable;
    };
  };

  migaduConfig = {
    flavor = "migadu.com";
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
      # Common configuration
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
      # Common configuration
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
