{ config, pkgs, ... }: {
  accounts.email.accounts.fastmail.address = "hey@samhatfield.me";
  accounts.email.accounts.fastmail.imap.host = "imap.fastmail.com";
  accounts.email.accounts.fastmail.passwordCommand = "pass fastmail";
  accounts.email.accounts.fastmail.primary = true;
  accounts.email.accounts.fastmail.realName = "Sam Hatfield";
  accounts.email.accounts.fastmail.smtp.host = "smtp.fastmail.com";
  accounts.email.accounts.fastmail.userName = "hey#samhatfield.me";
  accounts.email.accounts.fastmail.notmuch.enable = true;
  accounts.email.accounts.fastmail.msmtp.enable = true;
  accounts.email.accounts.fastmail.mbsync.enable = true;
  accounts.email.accounts.fastmail.mbsync.create = "both";
  home.file.".mailcap".text =
    "text/html;  w3m -dump -o document_charset=%{charset} '%s'; nametemplate=%s.html; copiousoutput";
  home.packages = with pkgs; [
    file
    gpa
    httpie
    nixfmt
    nix-prefetch-scripts
    pandoc
    python37Packages.editorconfig
    ripgrep
    w3m
    xclip
  ];
  nixpkgs.config.allowUnfree = true;
  programs.afew.enable = true;
  programs.afew.extraConfig = import ./afew-config.nix;
  programs.alot.enable = true;
  programs.alot.settings = {
    editor_cmd = "kak";
    envelope_html2txt = "pandoc -f html -t markdown";
    envelope_txt2html = "pandoc -t html";
  };
  programs.bat.enable = true;
  programs.command-not-found.enable = true;
  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;
  programs.emacs.enable = true;
  programs.feh.enable = true;
  programs.firefox.enable = true;
  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;
  programs.git.aliases.graph = "log --graph --oneline --decorate";
  programs.git.aliases.staged = "diff --cached";
  programs.git.enable = true;
  programs.git.extraConfig.init.defaultBranch = "main";
  programs.git.ignores = [ "result" "*~" ".#*" ];
  programs.git.signing.key = "hey@samhatfield.me";
  programs.git.signing.signByDefault = true;
  programs.git.userEmail = "hey@samhatfield.me";
  programs.git.userName = "sehqlr";
  programs.gpg.enable = true;
  programs.htop.enable = true;
  programs.kakoune.config.colorScheme = "solarized-dark";
  programs.kakoune.config.hooks = [
    {
      name = "WinCreate";
      option = "^[^*]+$";
      commands = "editorconfig-load";
    }
    {
      name = "BufCreate";
      option = "^.*md$";
      commands = ''
        set-option buffer modelinefmt 'wc:%sh{ cat "$kak_buffile" | wc -w} - %val{bufname} %val{cursor_line}:%val{cursor_char_column} {{context_info}} {{mode_info}} - %val{client}@[%val{session}]'
      '';
    }
    {
      name = "BufCreate";
      option = "^.*lhs$";
      commands = ''
        set-option buffer filetype markdown
      '';
    }
  ];
  programs.kakoune.config.numberLines.enable = true;
  programs.kakoune.config.showWhitespace.enable = true;
  programs.kakoune.config.ui.enableMouse = true;
  programs.kakoune.enable = true;
  programs.mbsync.enable = true;
  programs.msmtp.enable = true;
  programs.notmuch.enable = true;
  programs.notmuch.hooks.postNew = "afew -tn";
  programs.notmuch.hooks.preNew = "mbsync -a";
  programs.notmuch.new.tags = [ "new" ];
  programs.password-store.enable = true;
  programs.rofi.enable = true;
  programs.rofi.package =
    pkgs.rofi.override { plugins = with pkgs; [ rofi-emoji rofi-pass ]; };
  programs.rofi.theme = "lb"; # rofi-theme-selector
  programs.ssh.enable = true;
  programs.ssh.matchBlocks."bytes.zone".host = "git.bytes.zone";
  programs.ssh.matchBlocks."bytes.zone".port = 2222;
  programs.ssh.matchBlocks."bytes.zone".user = "git";
  programs.ssh.matchBlocks."github".host = "github.com";
  programs.ssh.matchBlocks."github".user = "git";
  programs.ssh.matchBlocks."gitlab".host = "gitlab.com";
  programs.ssh.matchBlocks."gitlab".user = "git";
  programs.ssh.matchBlocks."sr.ht".host = "*sr.ht";
  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;
  programs.starship.settings.add_newline = false;
  programs.starship.settings.character.symbol = "λ";
  programs.termite.enable = true;
  programs.tmux.enable = true;
  programs.tmux.clock24 = true;
  programs.zathura.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.enable = true;
  programs.zsh.oh-my-zsh.enable = true;
  programs.zsh.oh-my-zsh.plugins =
    [ "copyfile" "extract" "httpie" "pass" "sudo" "systemd" ];
  programs.zsh.oh-my-zsh.theme = "af-magic";
  programs.zsh.shellAliases.nixos = "sudo nixos-rebuild";
  services.emacs.enable = true;
  services.flameshot.enable = true;
  services.gpg-agent.enableSshSupport = true;
  services.gpg-agent.enable = true;
  services.gpg-agent.sshKeys = [ "87F5686AC11C5D0AE1C7D66B7AE4D820B34CF744" ];
  services.lorri.enable = true;
  xdg.configFile."afew/lobsters.py".source = ./lobsters.py;
  xsession.windowManager.xmonad.config = ./xmonad.hs;
  xsession.windowManager.xmonad.enableContribAndExtras = true;
  xsession.windowManager.xmonad.enable = true;
}
