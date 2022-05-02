{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  myName = "Antoine Martin";
  email_perso = "antoine@alarsyo.net";
  email_lrde = "amartin@lrde.epita.fr";

  cfg = config.my.home.mail;
in {
  options.my.home.mail = {
    # I *could* read email in a terminal emacs client on a server, but in
    # practice I don't think it'll happen very often, so let's enable this only
    # when I'm on a machine with a Xorg server.
    enable = (mkEnableOption "email configuration") // {default = config.my.home.x.enable;};
  };

  config = mkIf cfg.enable {
    accounts.email = {
      maildirBasePath = "${config.home.homeDirectory}/.mail";
      accounts = {
        alarsyo = {
          address = email_perso;
          userName = email_perso;
          realName = myName;
          aliases = [
            "alarsyo@alarsyo.net"
            "antoine@amartin.email"
          ];
          flavor = "plain"; # default setting
          passwordCommand = "${pkgs.rbw}/bin/rbw get webmail.migadu.com ${email_perso}";
          primary = true;
          mbsync = {
            enable = true;
            create = "both";
            expunge = "both";
            groups = {
              alarsyo-main.channels.alarsyo-main = {
                patterns = ["INBOX" "Sent" "Drafts" "Junk" "Trash"];
                extraConfig = {
                  Create = "Both";
                  Expunge = "Both";
                  Remove = "None";
                  SyncState = "*";
                };
              };
              alarsyo-full.channels.alarsyo-full = {
                patterns = ["*" "!INBOX" "!Sent" "!Drafts" "!Junk" "!Trash"];
                extraConfig = {
                  Create = "Both";
                  Expunge = "Both";
                  Remove = "None";
                  SyncState = "*";
                };
              };
            };
          };
          msmtp.enable = true;
          mu.enable = true;
          imap = {
            host = "imap.migadu.com";
            port = 993;
            tls.enable = true;
          };
          smtp = {
            host = "smtp.migadu.com";
            port = 465;
            tls.enable = true;
          };
        };
        lrde = {
          address = email_lrde;
          userName = "amartin";
          realName = myName;
          flavor = "plain"; # default setting
          passwordCommand = "${pkgs.rbw}/bin/rbw get lrde.epita.fr amartin";
          mbsync = {
            enable = true;
            create = "both";
            expunge = "both";
            patterns = ["*" "!Archives*"];
            extraConfig.account = {
              # otherwise mbsync tries GSSAPI, but I don't have Kerberos setup
              # on this machine
              AuthMechs = "LOGIN";
            };
          };
          msmtp.enable = true;
          mu.enable = true;
          imap = {
            host = "imap.lrde.epita.fr";
            port = 993;
            tls.enable = true;
          };
          smtp = {
            host = "smtp.lrde.epita.fr";
            port = 465;
            tls.enable = true;
          };
        };
      };
    };

    programs.mbsync.enable = true;
    programs.msmtp.enable = true;
    programs.mu.enable = true;
  };
}
