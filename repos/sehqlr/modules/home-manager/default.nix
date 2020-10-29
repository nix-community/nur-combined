{ config, lib, pkgs, ... }: {
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
    wofi
    xclip
  ];
  nixpkgs.config = import ./nixpkgs-config.nix;
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
  programs.firefox.enable = true;
  programs.firefox.package = pkgs.firefox-wayland;
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
  programs.kakoune.config.colorScheme = "red-phoenix";
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
    {
      name = "InsertChar";
      option = "j";
      commands = ''
        try %{
            exec -draft hH <a-k>jj<ret> d
            exec <esc>
        }
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
  programs.tmux.clock24 = true;
  programs.tmux.enable = true;
  programs.tmux.extraConfig = ''
    set -g mouse on
  '';
  programs.tmux.terminal = "tmux-256color";
  programs.tmux.shortcut = "a";
  programs.waybar.enable = true;
  programs.waybar.settings = [
    {
      layer = "top";
      position = "top";
      modules-left = [ "sway/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [ "tray" ];
    }
    {
      layer = "top";
      position = "bottom";
      modules-left = [ "sway/window" ];
      modules-center = [ ];
      modules-right = [ "network" "cpu" "memory" "battery" ];
    }
  ];
  programs.waybar.systemd.enable = true;
  programs.zathura.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.enable = true;
  programs.zsh.oh-my-zsh.enable = true;
  programs.zsh.oh-my-zsh.plugins =
    [ "copyfile" "extract" "httpie" "pass" "sudo" "systemd" ];
  programs.zsh.oh-my-zsh.theme = "af-magic";
  programs.zsh.shellAliases.nixos = "sudo nixos-rebuild";
  services.kanshi.enable = true;
  services.gpg-agent.enableSshSupport = true;
  services.gpg-agent.enable = true;
  services.gpg-agent.sshKeys = [ "87F5686AC11C5D0AE1C7D66B7AE4D820B34CF744" ];
  services.lorri.enable = true;
  services.udiskie.enable = true;
  wayland.windowManager.sway.config.bars =
    [{ command = "${pkgs.waybar}/bin/waybar"; }];
  wayland.windowManager.sway.config.input."type:touchpad".tap = "enabled";
  wayland.windowManager.sway.config.keybindings =
    let modifier = config.wayland.windowManager.sway.config.modifier;
    in lib.mkOptionDefault {
      "${modifier}+Return" = "exec ${pkgs.termite}/bin/termite -e tmux";
      "${modifier}+p" =
        "exec ${pkgs.wofi}/bin/wofi -S run,drun | ${pkgs.findutils}/bin/xargs swaymsg exec --";
    };
  wayland.windowManager.sway.config.modifier = "Mod4";
  wayland.windowManager.sway.config.terminal = "${pkgs.termite}/bin/termite";
  wayland.windowManager.sway.enable = true;
  xdg.configFile."afew/lobsters.py".source = ./lobsters.py;
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;
}
