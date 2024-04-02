{ config, pkgs, lib, data, ... }:
let
  p = with pkgs; {


    net = [
      # anti-censor
      [ sing-box rathole tor arti tuic phantomsocks ]

      [ stun bandwhich fscan iperf3 i2p ethtool dnsutils autossh tcpdump netcat dog wget mtr-gui socat miniserve mtr wakelan q nali lynx nethogs restic w3m whois dig wireguard-tools curlHTTP3 xh ngrep gping knot-dns tcping-go httping iftop ]
    ];
    # graph = [
    #   vulkan-validation-layers
    # ];

    cmd = [

      smartmontools
      difftastic
      direnv
      btop
      atuin
      minio-client
      attic
      deno
      ntfy-sh
      _7zz
      yazi
      rclone

      distrobox
      dmidecode

      helix
      srm
      # onagre
      libsixel
      ouch
      nix-output-monitor
      kitty

      # common
      [ killall hexyl jq fx bottom lsd fd choose duf tokei procs lsof tree bat ]
      [ broot powertop ranger ripgrep qrencode lazygit b3sum unzip zip coreutils inetutils pciutils usbutils ]
    ];
    # # ripgrep-all 


    info = [ freshfetch htop onefetch hardinfo hyprpicker imgcat nix-index ccze ];

  };
in
{
  environment.systemPackages =
    lib.flatten (lib.attrValues p)
    ++
    (with pkgs; [ unar podman-compose docker-compose ]) ++
    [
      ((pkgs.vim_configurable.override { }).customize {
        name = "vim";
        # Install plugins for example for syntax highlighting of nix files
        vimrcConfig.packages.myplugins = with pkgs.vimPlugins; {
          start = [ vim-nix vim-lastplace ];
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
      }
      )
    ]
    ++
    lib.optionals (!(lib.elem config.networking.hostName data.withoutHeads))
      (with pkgs.nodePackages; [
        vscode-json-languageserver
        typescript-language-server
        vscode-css-languageserver-bin
        node2nix
        markdownlint-cli2
        prettier
      ])

  ;
}

  
