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
  programs.afew.extraConfig = ''
    [SpamFilter]
    [KillThreadsFilter]
    [ListMailsFilter]
    [ArchiveSentMailsFilter]

    [Filter.0]
    query   = 'from:angel.co'
    tags    =  +news;-new
    message = angel.co news updates

    [Filter.1]
    query   = 'from:booksite.com'
    tags    =  +news;-new
    message = booksite.com news updates

    [Filter.2]
    query   = 'from:coursera.org'
    tags    =  +news;-new
    message = coursera.org news updates

    [Filter.3]
    query   = 'from:creditkarma.com'
    tags    =  +news;-new
    message = creditkarma.com news updates

    [Filter.4]
    query   = 'from:datacamp.com'
    tags    =  +news;-new
    message = datacamp.com news updates

    [Filter.5]
    query   = 'from:datasciencedigest'
    tags    =  +news;-new
    message = datasciencedigest news updates

    [Filter.6]
    query   = 'from:getpocket.com'
    tags    =  +news;-new
    message = getpocket.com news updates

    [Filter.7]
    query   = 'from:khanacademy.org'
    tags    =  +news;-new
    message = khanacademy.org news updates

    [Filter.8]
    query   = 'from:lyftmail.com'
    tags    =  +news;-new
    message = lyftmail.com news updates

    [Filter.9]
    query   = 'from:makingfun.com'
    tags    =  +news;-new
    message = makingfun.com news updates

    [Filter.10]
    query   = 'from:manning.com'
    tags    =  +news;-new
    message = manning.com news updates

    [Filter.11]
    query   = 'from:mastermindroomescape@gmail.com'
    tags    =  +news;-new
    message = mastermindroomescape@gmail.com news updates

    [Filter.12]
    query   = 'from:oreilly.com'
    tags    =  +news;-new
    message = oreilly.com news updates

    [Filter.13]
    query   = 'from:patreon.com'
    tags    =  +news;-new
    message = patreon.com news updates

    [Filter.14]
    query   = 'from:paypal.com'
    tags    =  +news;-new
    message = paypal.com news updates

    [Filter.15]
    query   = 'from:petersmktg.com'
    tags    =  +news;-new
    message = petersmktg.com news updates

    [Filter.16]
    query   = 'from:postman.com'
    tags    =  +news;-new
    message = postman.com news updates

    [Filter.17]
    query   = 'from:postmates.com'
    tags    =  +news;-new
    message = postmates.com news updates

    [Filter.18]
    query   = 'from:puttylike.com'
    tags    =  +news;-new
    message = puttylike.com news updates

    [Filter.19]
    query   = 'from:redhat.com'
    tags    =  +news;-new
    message = redhat.com news updates

    [Filter.20]
    query   = 'from:slpl.org'
    tags    =  +news;-new
    message = slpl.org news updates

    [Filter.21]
    query   = 'from:spotify.com'
    tags    =  +news;-new
    message = spotify.com news updates

    [Filter.22]
    query   = 'from:steampowered.com'
    tags    =  +news;-new
    message = steampowered.com news updates

    [Filter.23]
    query   = 'from:stlpublicradio.org'
    tags    =  +news;-new
    message = stlpublicradio.org news updates

    [Filter.24]
    query   = 'from:stitchfix.com'
    tags    =  +news;-new
    message = stitchfix.com news updates

    [Filter.25]
    query   = 'from:umsl.edu'
    tags    =  +news;-new
    message = umsl.edu news updates

    [Filter.26]
    query   = 'from:univa.com'
    tags    =  +news;-new
    message = univa.com news updates

    [Filter.27]
    query   = 'from:wordpress.com'
    tags    =  +news;-new
    message = wordpress.com news updates

    [Filter.28]
    query   = 'from:zmag.org'
    tags    =  +news;-new
    message = zmag.org news updates

    [Filter.29]
    query   = 'from:zombiesrungame.com'
    tags    =  +news;-new
    message = zombiesrungame.com news updates

    [Filter.30]
    query   = 'from:facebook.com'
    tags    =  +social;-new
    message = facebook.com social network updates

    [Filter.31]
    query   = 'from:linkedin.com'
    tags    =  +social;-new
    message = linkedin.com social network updates

    [Filter.32]
    query   = 'from:reddit.com'
    tags    =  +social;-new
    message = reddit.com social network updates

    [Filter.33]
    query   = 'from:meetup.com'
    tags    =  +meetup;+social;+news;-new
    message = Meetup.com updates

    [Filter.34]
    query   = 'from:websterum.org'
    tags    =  -new
    message = deleting this because I don't want to email them to take me off the list

    [Filter.35]
    query   = 'to:hey@samhatfield.me AND from:hey@samhatfield.me'
    tags    =  -new;+bookmark
    message = Sending myself bookmarks, don't need in the inbox

    [Filter.36]
    query   = 'tag:lists'
    tags    = -new
    message = Autoarchive mailinglists

    [LobstersFilter]

    [InboxFilter]

    [MailMover]
    rename = True
    folders = "fastmail/Spam" "gmail/Spam" "fastmail/Inbox" "gmail/Inbox"

    fastmail/Spam = 'not tag:spam':"fastmail/Archive"
    gmail/Spam = 'NOT tag:spam':"gmail/[Gmail]/All Mail"
    fastmail/Inbox = 'NOT tag:inbox':"fastmail/Archive"
    gmail/Inbox = 'NOT tag:inbox':"gmail/[Gmail]/All Mail"
  '';
  programs.alot.enable = true;
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
  programs.kakoune.config.hooks = [{
    name = "WinCreate";
    option = "^[^*]+$";
    commands = "editorconfig-load";
  }];
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
