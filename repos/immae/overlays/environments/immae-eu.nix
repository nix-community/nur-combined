self: super: with self;
let
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/stdenv/generic/setup.sh
  # https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks
  paths = [
    # archives
    lzo unzip bzip2 p7zip xz
    # unrar is unfree

    # backups
    duply

    # calendar/contacts
    abook khard khal cadaver vdirsyncer pal

    # computing
    boinctui

    # cryptocurrencies
    cardano sia monero
    xmr-stak
    solc
    iota-cli-app

    # debugging
    rr valgrind netcat-gnu strace shellcheck

    # documentations
    unicodeDoc

    # e-mails
    muttprint mutt-ics
    notmuch-python2 notmuch-python3 notmuch-vim
    neomutt mairix notmuch
    bogofilter fetchmail

    # git
    vcsh gitRepo gitAndTools.stgit tig

    # graphical tools
    nextcloud-client firefox
    dwm dmenu st

    # images
    feh imagemagick tiv graphicsmagick

    # internet browsing
    w3m lynx links elinks browsh weboob urlview googler urlwatch

    # less
    python3Packages.pygments lesspipe highlight sourceHighlight

    # monitoring
    cnagios mtop pg_activity nagios-cli mtr
    iftop htop iotop iperf
    goaccess
    # nagnu

    # messaging/forums/news
    flrn slrn
    telegram-cli telegram-history-dump telegramircd
    weechat profanity
    newsboat irssi

    # nix
    mylibs.yarn2nixPackage.yarn2nix
    nixops nix-prefetch-scripts nix-generate-from-cpan
    nix-zsh-completions bundix nodePackages.bower2nix
    nodePackages.node2nix
    # (nixos {}).nixos-generate-config
    # (nixos {}).nixos-install
    # (nixos {}).nixos-enter
    # (nixos {}).manual.manpages

    # note taking
    note terminal-velocity jrnl

    # office
    sc-im ranger
    genius bc
    ledger
    tmux
    rtorrent
    ldapvi

    # password management
    pass apg pwgen

    # pdf
    pdftk poppler_utils

    # programming
    pelican emacs26-nox ctags
    wdiff

    # security
    keybase

    # todolist/time management
    taskwarrior vit timewarrior

    # video/music
    youtube-dl ncmpc ncmpcpp ffmpeg

    # other tools
    pgloader s3cmd lftp jq cpulimit libxslt
  ];
in
{
  myEnvironments.immae-eu = buildEnv {
    name = "immae-eu-packages";
    inherit paths;
    pathsToLink = [ "/bin" "/etc" "/include" "/lib" "/libexec" "/share"];
    extraOutputsToInstall = [ "bin" "man" "doc" "info" ];
  };
}
