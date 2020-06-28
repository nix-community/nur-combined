{ config, lib, pkgs, ... }: {
  xdg.configFile."afew/lobsters.py".source = ./lobsters.py;

  accounts.email.accounts.fastmail = {
    address = "hey@samhatfield.me";
    imap.host = "imap.fastmail.com";
    passwordCommand = "pass email/fastmail.com/home-manager";
    primary = true;
    realName = "Sam Hatfield";
    smtp.host = "smtp.fastmail.com";
    userName = "hey#samhatfield.me";

    notmuch.enable = true;
    msmtp.enable = true;
    mbsync = {
      create = "both";
      enable = true;
    };
  };

  programs.notmuch = {
    enable = true;
    hooks.postNew = "afew -tn";
    hooks.preNew = "mbsync -a";
    new.tags = [ "new" ];
  };

  programs.afew.enable = true;
  programs.alot.enable = true;
  home.file.".mailcap".text =
    "text/html;  w3m -dump -o document_charset=%{charset} '%s'; nametemplate=%s.html; copiousoutput";
  programs.mbsync.enable = true;
  programs.msmtp.enable = true;
}
