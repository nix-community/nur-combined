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

      programs.astroid = {
        enable = true;
        pollScript = "afew -m";
        extraConfig = {
          editor.cmd = "urxvt -embed %3 -e kak %1";
          startup.queries = {
            todo = "tag:flagged";
            social = "tag:social";
            reading_list = "tag:unread AND (tag:news OR tag:lists)";
          };
          thread_view = {
            default_save_directory = "~/Downloads";
            indent_messages = true;
            preferred_html_only = true;
          };
        };
      };
      # TODO get this working
      # xdg.configFile."astroid/plugins/syntax-highlight" = fetchFromGitHub {
      #   owner = "astroidmail";
      #   repo = "syntax-highlight";
      # }

}
