{
  flake.modules.nixos.dev-pkgs =
    { pkgs, lib, ... }:
    {

      environment.systemPackages = lib.flatten (
        lib.attrValues (
          with pkgs;
          {
            python = [
              (
                (python313.override {
                  enableOptimizations = true;
                  reproducibleBuild = false;
                }).withPackages
                (
                  ps: with ps; [
                    pandas
                    requests
                    # absl-py
                    tldextract
                    bleak
                    matplotlib
                    clang
                    pyyaml
                  ]
                )
              )
            ];
            crypt = [
              # (openssl.override {
              #   conf = pkgs.writeText "openssl.conf" ''
              #     openssl_conf = openssl_init
              #     [openssl_init]
              #     engines = engine_section
              #     ssl_conf = ssl_module
              #     [engine_section]
              #     pkcs11 = pkcs11_section
              #     [pkcs11_section]
              #     engine_id = pkcs11
              #     dynamic_path = ${pkgs.libp11}/lib/engines/libpkcs11.so
              #     MODULE_PATH = ${pkgs.opensc}/lib/opensc-pkcs11.so
              #     init = 0
              #   '';
              # })
              minisign
              ent
              rage
              age-plugin-yubikey
              cryptsetup
              tpm2-tss
              tpm2-tools
              yubikey-manager
              monero-cli
              yubikey-personalization
              opensc
              sbctl
            ];

            dev = [
              (nixos-rebuild-ng.override {
                # withNgSuffix = false;
                nix = pkgs.lixPackageSets.stable.lix;
              })
              zola
              devenv
              zoxide
              nodejs_latest
              wakelan
              lynx
              opencode
              atuin
              yazi
              hexyl
              shpool
              ouch
              libsixel
              difftastic
              btop
              minio-client
              fscan
              i2p
              ethtool
              git-credential-oauth
              qrencode
              lazygit
              codex
              gemini-cli
              docker-compose
              antigravity
              gh
              # zed-editor
              # vscode.fhs
              # nodejs_latest.pkgs.pnpm
              # nodejs_latest
              qemu-utils
              # rustup
              perf
              strace
              gitoxide
              gitui
              nushell
              # radicle
              # friture

              pv
              # gnome.dconf-editor

              [
                bpf-linker
                gdb
                gcc
                gnumake
                cmake
              ]
              lua
              # delta
              go
              nix-tree
              kotlin
              inotify-tools
              tmux

              trunk
              cargo-expand
              wasmtime
              comma
              nix-update
              osgint
            ];

            lang = [
              [
                editorconfig-checker
                kotlin-language-server
                lua-language-server
                yaml-language-server
                tree-sitter
                stylua
                # biome
                # black
              ]
              # languages related
              [
                zig
                # lldb
                # haskell-language-server
                gopls
                cmake-language-server
                zls
                android-file-transfer
                nixpkgs-review
                shfmt
                #   markdown-oxide
              ]
              [
                #   vscode-langservers-extracted
                bash-language-server
                texlab
              ]
              [
                # rust-analyzer
                # nil
                nixd
                nil
                shfmt
                nixfmt
                ruff
                ty
                # taplo
                rustfmt
                clang-tools
                # haskell-language-server
                cmake-language-server
                arduino-language-server

                vhdl-ls
                #   delve
                # python311Packages.python-lsp-server
                taplo
                tinymist
              ]
            ];
            # wine = [
            #   # bottles
            #   wineWowPackages.stable

            #   # support 32-bit only
            #   # wine

            #   # support 64-bit only
            #   (wine.override { wineBuild = "wine64"; })

            #   # wine-staging (version with experimental features)
            #   wineWowPackages.staging

            #   # winetricks (all versions)
            #   winetricks

            #   # native wayland support (unstable)
            #   wineWowPackages.waylandFull
            # ];

            # db = [ mongosh ];

            web = [ hugo ];

            # de = with gnomeExtensions; [
            #   # simple-net-speed
            #   paperwm
            # ];
            term = [ foot ]; # for spawn new

            virt = [
              # virt-manager
              virtiofsd

              # runwin
              # guix-run
              # runbkworm
              # bkworm
              # arch-run
              # lunar-run

              # ubt-rv-run
              #opulr-a-run
              # virt-viewer
            ];
            fs = [
              gparted
              e2fsprogs
              fscrypt-experimental
              f2fs-tools
              cifs-utils
            ];

            cmd = [
              metasploit
              # linuxKernel.packages.linux_latest_libre.cpupower
              just
              typst
              cosmic-term
              hyperfine
              acpi
              swww
              distrobox
              gum
              dmidecode
              nix-output-monitor
              numbat
              fend
              rustic
              systemctl-tui
              uv

            ];
            info = [
              parallel-disk-usage # disk space info
              freshfetch
              htop
              onefetch
              hardinfo2
              vicinae
              imgcat
              nix-index
              ccze
              unar

            ];
            editor = [
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
            bluetooth = [ bluetuith ];

            sound = [ pulseaudio ];

            display = [ cage ];

            cursor = [ bibata-cursors ];
            vcs = [
              jujutsu
              # lazyjj
            ];
          }
        )
      );

    };
}
