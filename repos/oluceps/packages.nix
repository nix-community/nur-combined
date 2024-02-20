{ config, pkgs, lib, data, inputs, ... }:
let
  p = with pkgs; {


    net = [
      # anti-censor
      [ sing-box rathole tor arti tuic phantomsocks ]

      [ stun bandwhich fscan iperf3 i2p ethtool dnsutils autossh tcpdump netcat dog wget mtr-gui socat miniserve mtr wakelan q nali lynx nethogs restic w3m whois dig wireguard-tools curlHTTP3 xh ngrep gping knot-dns tcping-go httping ]
    ];
    # graph = [
    #   vulkan-validation-layers
    # ];

    cmd = [
      _7zz
      yazi
      rclone

      distrobox
      dmidecode

      helix
      srm
      onagre
      libsixel
      ouch
      nix-output-monitor
      kitty

      # common
      [ killall hexyl jq fx bottom lsd fd choose duf tokei procs lsof tree bat ]
      [ broot powertop ranger ripgrep qrencode lazygit b3sum unzip zip coreutils inetutils pciutils usbutils ]
    ];
    # # ripgrep-all 


    info = [ freshfetch htop onefetch hardinfo qjournalctl hyprpicker imgcat nix-index ccze ];

  };

  # extra
  e = with pkgs;{
    crypt = [ minisign rage age-plugin-yubikey cryptsetup tpm2-tss tpm2-tools yubikey-manager yubikey-manager-qt monero-cli ];

    python = [ (python311.withPackages (ps: with ps; [ pandas requests absl-py tldextract bleak dotenv ])) ];

    lang = [
      [
        editorconfig-checker
        kotlin-language-server
        sumneko-lua-language-server
        yaml-language-server
        tree-sitter
        stylua
        # black
      ]
      # languages related
      [ zig lldb haskell-language-server gopls cmake-language-server zls android-file-transfer nixpkgs-review shfmt ]
    ];
    wine = [
      # bottles
      wineWowPackages.stable

      # support 32-bit only
      # wine

      # support 64-bit only
      (wine.override { wineBuild = "wine64"; })

      # wine-staging (version with experimental features)
      wineWowPackages.staging

      # winetricks (all versions)
      winetricks

      # native wayland support (unstable)
      wineWowPackages.waylandFull
    ];
    dev = [
      friture
      qemu-utils
      yubikey-personalization
      racket
      resign
      pv
      devenv
      gnome.dconf-editor
      [ swagger-codegen3 bump2version openssl linuxPackages_latest.perf cloud-utils ]
      [ bpf-linker gdb gcc gnumake cmake ] # clang-tools_15 llvmPackages_latest.clang ]
      # [ openocd ]
      lua
      delta
      # nodejs-18_x
      switch-mute
      go


      nix-tree
      kotlin
      jre17_minimal
      inotify-tools
      rustup
      minio-client
      tmux
      # awscli2


      trunk
      cargo-expand
      wasmer
      wasmtime
      comma
      nix-update
      nodejs_latest.pkgs.pnpm
    ];
    db = [ mongosh ];

    web = [ hugo ];

    de = with gnomeExtensions;[ simple-net-speed blur-my-shell ];

    virt = [
      # virt-manager
      virtiofsd
      runwin
      guix-run
      runbkworm
      bkworm
      arch-run
      # ubt-rv-run
      #opulr-a-run
      lunar-run
      virt-viewer
    ];
    fs = [ gparted e2fsprogs fscrypt-experimental f2fs-tools compsize ];

    cmd =
      [
        metasploit
        linuxKernel.packages.linux_latest_libre.cpupower
        clean-home
        just
        typst
        cosmic-term
      ];
    bluetooth = [ bluetuith ];

    sound = [ pulseaudio ];

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
      ((lib.flatten
        (lib.attrValues e))
      ++
      (with pkgs.nodePackages; [
        vscode-json-languageserver
        typescript-language-server
        vscode-css-languageserver-bin
        node2nix
        markdownlint-cli2
        prettier
      ])
      )
  ;
}

  
