{
  config,
  pkgs,
  lib,
  data,
  ...
}:
let
  p = with pkgs; {

    net = [
      # anti-censor
      [
        sing-box
        tor
        arti
        oniux
      ]

      [
        rustscan
        stun
        bandwhich
        fscan
        iperf3
        i2p
        ethtool
        dnsutils
        tcpdump
        netcat
        wget
        socat
        miniserve
        mtr
        wakelan
        q
        nali
        lynx
        nethogs
        w3m
        whois
        dig
        wireguard-tools
        # curlFull
        (curlECH.override {
          ldapSupport = true;
          gsaslSupport = true;
          rtmpSupport = true;
          pslSupport = true;
          websocketSupport = true;
          echSupport = true;
        })
        xh
        # ngrep
        gping
        tcping-go
        # httping
        iftop
      ]
    ];
    cmd = [
      eza
      fzf
      mcrcon
      zola

      smartmontools
      difftastic
      btop
      atuin
      minio-client
      # attic
      ntfy-sh
      _7zz
      yazi
      rclone

      helix
      srm
      # onagre
      libsixel
      ouch

      # common
      [
        killall
        hexyl
        jq
        fx
        bottom
        lsd
        fd
        choose
        duf
        tokei
        procs
        lsof
        tree
        bat
      ]
      [
        broot
        ranger
        ripgrep
        qrencode
        lazygit
        b3sum
        coreutils
        juicefs
        # inetutils
        traceroute
        pciutils
        usbutils
        rsync
      ]
    ];
    # # ripgrep-all

  };
in
{
  environment.systemPackages = lib.flatten (lib.attrValues p) ++ [
    ((pkgs.vim-full.override { }).customize {
      name = "vim";
      # Install plugins for example for syntax highlighting of nix files
      vimrcConfig.packages.myplugins = with pkgs.vimPlugins; {
        start = [
          vim-nix
          vim-lastplace
        ];
        opt = [ ];
      };
      vimrcConfig.customRC = ''
        " your custom vimrc
        set nocompatible
        set backspace=indent,eol,start
        " Turn on syntax highlighting by default
        syntax on

        :let mapleader = " "
        :map <leader>s :w<cr>
        :map <leader>q :q<cr>
        :map <C-j> 5j
        :map <C-k> 5k
      '';
    })
  ];
}
