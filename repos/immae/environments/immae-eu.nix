{ pkgs }: with pkgs;
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
    cardano cardano-cli sia monero
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
    neomutt mairix
    bogofilter fetchmail
    sieve-connect

    # git
    vcsh gitRepo gitAndTools.stgit tig ripgrep mr

    # graphical tools
    nextcloud-client firefox
    dwm dmenu st xorg.xauth tigervnc

    # images
    feh imagemagick tiv graphicsmagick qrcode

    # internet browsing
    w3m lynx links elinks browsh weboob urlview urlscan googler urlwatch

    # less
    python3Packages.pygments lesspipe highlight sourceHighlight

    # monitoring
    cnagios mtop pg_activity nagios-cli mtr
    iftop htop iotop iperf bonfire
    goaccess tcpdump tshark tcpflow mitmproxy
    # nagnu

    # messaging/forums/news
    #flrn slrn
    telegram-cli telegram-history-dump telegramircd
    weechat profanity
    newsboat irssi

    # nix
    yarn2nix-moretea.yarn2nix nix
    nixops nix-prefetch-scripts nix-generate-from-cpan
    bundix nodePackages.bower2nix
    nodePackages.node2nix niv
    # (nixos {}).nixos-generate-config
    # (nixos {}).nixos-install
    # (nixos {}).nixos-enter
    # (nixos {}).manual.manpages

    # note taking
    note terminal-velocity jrnl doing

    # office
    sc-im ranger
    genius bc
    ledger
    tmux
    rtorrent
    ldapvi
    fzf
    buku
    vimPlugins.vim-plug
    (vim_configurable.override { python = python3; })
    mailcap

    # password management
    (pass.withExtensions (exts: [ exts.pass-otp ])) apg pwgen

    # pdf
    pdftk poppler_utils

    # programming
    pelican emacs26-nox ctags
    wdiff patch gnumake

    # security
    keybase gnupg

    # todolist/time management
    taskwarrior vit timewarrior

    # video/music
    youtube-dl ncmpc ncmpcpp ffmpeg

    # s6 tools (part of skawarePackages)
    skalibs execline s6 s6-dns s6-linux-utils s6-networking
    s6-portable-utils

    # system tools
    telnet bind.dnsutils httpie ngrep nmap p0f socat lsof psmisc
    wget patchelf rename tmux (lib.meta.hiPrio nettools)
    vlock mosh manpages openssl

    # other tools
    pgloader s3cmd lftp jq cpulimit libxslt gandi-cli

    # Terraform + AWS
    terraform_0_12 awscli
    (ansible.override { python2 = python3; }) python3Packages.boto
    openvpn
  ];
in
buildEnv {
  name = "immae-eu-packages";
  inherit paths;
  pathsToLink = [ "/bin" "/etc" "/include" "/lib" "/libexec" "/share"];
  extraOutputsToInstall = [ "bin" "man" "doc" "info" ];
  passthru = { packages = paths; };
}
