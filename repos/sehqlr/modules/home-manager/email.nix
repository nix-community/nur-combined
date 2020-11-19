{ config, lib, pkgs, ... }: {
  accounts.email.accounts.fastmail = {
    realName = "Sam Hatfield";
    address = "hey@samhatfield.me";
    primary = true;

    imap.host = "imap.fastmail.com";
    smtp.host = " smtp.fastmail.com";
    userName = "hey#samhatfield.me";
    passwordCommand = "op get item fastmail --fields password";

    notmuch.enable = true;
    msmtp.enable = true;
    mbsync = {
      enable = true;
      create = "both";
    };
  };

  programs.afew = {
    enable = true;
    extraConfig = import ./afew-config.nix;
  };
  xdg.configFile."afew/lobsters.py".source = ./lobsters.py;

  programs.alot = {
    enable = true;
    settings = {
      editor_cmd = "kak";
      envelope_html2txt = "pandoc -f html -t markdown";
      envelope_txt2html = "pandoc -t html";
    };
  };
  home.file.".mailcap".text =
    "text/html;  w3m -dump -o document_charset=%{charset} '%s'; nametemplate=%s.html; copiousoutput";
  home.packages = with pkgs; [ _1password pandoc w3m ];

  programs.mbsync.enable = true;
  programs.msmtp.enable = true;
  programs.notmuch = {
    enable = true;
    hooks = {
      postNew = "afew -tn";
      preNew = "eval $(op signin my) && mbsync -a";
    };
    new.tags = [ "new" ];
  };
}
