{ config, lib, pkgs, ... }:
{
      home.packages = [ pkgs.rxvt_unicode ];
      xdg.configFile."afew/lobsters.py".source = ./lobsters.py;

      accounts.email.accounts = {
        fastmail = {
          address = "hey@samhatfield.me";
          imap.host = "imap.fastmail.com";
          passwordCommand = "pass email/fastmail.com/home-manager";
          primary = true;
          realName = "Sam Hatfield";
          smtp.host = "smtp.fastmail.com";
          userName = "hey#samhatfield.me";

          notmuch.enable = true;
          astroid.enable = true;
          msmtp.enable = true;
          mbsync = {
            create = "both";
            enable = true;
            expunge = "both";
          };
        };
        gmail = {
          address = "samuel.e.hatfield@gmail.com";
          flavor = "gmail.com";
          passwordCommand = "pass email/gmail.com/home-manager";
          realName = "Sam Hatfield";

          notmuch.enable = true;
          astroid.enable = true;
          msmtp.enable = true;
          mbsync = {
            create = "both";
            enable = true;
            expunge = "both";
          };
        };
      };

      programs.mbsync.enable = true;
      programs.msmtp.enable = true;

      programs.notmuch = {
        enable = true;
        hooks.postNew = "afew -tn";
        hooks.preNew = "mbsync -a";
        new.tags = [ "new" ];
      };

      programs.afew = {
        enable = true;
      };
      programs.alot = {
          enable = true;
          };
}
