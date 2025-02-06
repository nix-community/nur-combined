{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mapAttrs
    mkEnableOption
    mkIf
    ;
  inherit
    (builtins)
    typeOf
    ;

  myName = "Antoine Martin";
  email_perso = "antoine@alarsyo.net";
  email_lrde = "amartin@lrde.epita.fr";
  email_prologin = "antoine.martin@prologin.org";

  cfg = config.my.home.mail;

  make_mbsync_channel = patterns:
    (
      if (typeOf patterns) == "list"
      then {
        inherit patterns;
      }
      else {
        farPattern = patterns.far;
        nearPattern = patterns.near;
      }
    )
    // {
      extraConfig = {
        Create = "Both";
        Expunge = "Both";
        Remove = "None";
        SyncState = "*";
      };
    };
  make_mbsync_channels = mapAttrs (_: value: make_mbsync_channel value);

  gmail_far_near_patterns = {
    sent = {
      far = "[Gmail]/Sent Mail";
      near = "Sent";
    };
    drafts = {
      far = "[Gmail]/Drafts";
      near = "Drafts";
    };
    junk = {
      far = "[Gmail]/Spam";
      near = "Junk";
    };
    trash = {
      far = "[Gmail]/Trash";
      near = "Trash";
    };
  };
  gmail_mbsync_channels = make_mbsync_channels gmail_far_near_patterns;
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
            "mail@antoinemartin.fr"
          ];
          flavor = "plain"; # default setting
          passwordCommand = "${pkgs.rbw}/bin/rbw get webmail.migadu.com ${email_perso}";
          primary = true;
          mbsync = {
            enable = true;
            create = "both";
            expunge = "both";
            groups = {
              alarsyo-main.channels = make_mbsync_channels {
                main = ["INBOX" "Sent" "Drafts" "Junk" "Trash"];
              };
              alarsyo-full.channels = make_mbsync_channels {
                full = ["*" "!INBOX" "!Sent" "!Drafts" "!Junk" "!Trash"];
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
        prologin = {
          address = email_prologin;
          userName = email_prologin;
          realName = myName;
          aliases = [
            "alarsyo@prologin.org"
          ];
          flavor = "plain"; # default setting
          passwordCommand = "${pkgs.rbw}/bin/rbw get google.com ${email_prologin}-mailpass";
          primary = false;
          mbsync = {
            enable = true;
            create = "both";
            expunge = "both";
            groups = {
              prologin-main.channels =
                (make_mbsync_channels {
                  main = ["INBOX" "membres@"];
                })
                // gmail_mbsync_channels;
              prologin-info.channels = make_mbsync_channels {
                info = ["info@" "info@gcc"];
              };
            };
          };
          msmtp.enable = true;
          mu.enable = true;
          imap = {
            host = "imap.gmail.com";
            port = 993;
            tls.enable = true;
          };
          smtp = {
            host = "smtp.gmail.com";
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
