{
  pkgs,
  lib,
  user,
  config,
  inputs',
  ...
}:
{
  systemd.tmpfiles.rules = [
    "L+ /home/${user}/.ssh/config - - - - ${pkgs.writeText "ssh-config" ''
      ${lib.concatLines (
        let
          hosts = lib.data.node;
        in
        lib.mapAttrsToList (n: v: ''
          Host ${n}
              HostName ${
                if lib.elem config.networking.hostName [ "kaambl" ] then
                  lib.getAddrFromCIDR v.unique_addr
                else if v ? addrs then
                  lib.elemAt v.addrs 0
                else
                  (lib.elemAt v.identifiers 0).name
              }
              User ${v.user}
              AddKeysToAgent yes
              ForwardAgent yes
        '') hosts
      )}
      Host gitee.com
          HostName gitee.com
          User riro

      Host github.com
          HostName ssh.github.com
          User git
          Port 443

      Host git.dn42.dev
          HostName git.dn42.dev
          User git
          Port 22

      Host *
          # ControlMaster auto
          # ControlPath ~/.ssh/%r@%h:%p.socket
          # ControlPersist 10m
          Port 22
          IdentityFile /persist/keys/sept
    ''}"
    "L+ /root/.ssh/config - - - - /home/${user}/.ssh/config"
  ];
  programs = {

    ssh = {
      # startAgent = true;
      enableAskPassword = true;
      askPassword = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
    };
    nh = {
      enable = true;
      # clean.enable = true;
      # clean.extraArgs = "--keep-since 4d --keep 7";
      flake = "/home/${user}/Src/nixos";
    };

    git.enable = true;
    bash.interactiveShellInit = ''
      eval "$(${lib.getExe pkgs.atuin} init bash)"
    '';
    fish.interactiveShellInit = ''
      ${lib.getExe pkgs.atuin} init fish | source
      ${lib.getExe pkgs.zoxide} init fish | source
    '';
    direnv = {
      enable = true;
      package = pkgs.direnv;
      silent = false;
      loadInNixShell = true;
      direnvrcExtra = "";
      nix-direnv = {
        enable = true;
        package = pkgs.nix-direnv;
      };
    };

  };
  environment.systemPackages =
    lib.flatten (
      lib.attrValues (
        with pkgs;
        {
          python = [
            (python313.withPackages (
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
            ))
          ];
          crypt = [
            (openssl.override {
              conf = pkgs.writeText "openssl.conf" ''
                openssl_conf = openssl_init
                [openssl_init]
                engines = engine_section
                ssl_conf = ssl_module
                [engine_section]
                pkcs11 = pkcs11_section
                [pkcs11_section]
                engine_id = pkcs11
                dynamic_path = ${pkgs.libp11}/lib/engines/libpkcs11.so
                MODULE_PATH = ${pkgs.opensc}/lib/opensc-pkcs11.so
                init = 0
              '';
            })
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
              withNgSuffix = false;
              # nix = inputs'.lix-module.packages.default;
            })
            devenv
            zoxide
            nodejs_latest
            zed-editor
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
            delta
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
              sumneko-lua-language-server
              yaml-language-server
              tree-sitter
              stylua
              biome
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
              markdown-oxide
            ]
            [
              vscode-langservers-extracted
              bash-language-server
              texlab
            ]
            [
              # rust-analyzer
              # nil
              nixd
              nil
              shfmt
              nixfmt-rfc-style
              ruff
              ty
              # taplo
              rustfmt
              clang-tools
              # haskell-language-server
              cmake-language-server
              arduino-language-server

              vhdl-ls
              delve
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

          db = [ mongosh ];

          web = [ hugo ];

          de = with gnomeExtensions; [
            simple-net-speed
            paperwm
          ];

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
            dmidecode
            nix-output-monitor
            numbat
            fend
            rustic

          ];
          info = [
            parallel-disk-usage # disk space info
            freshfetch
            htop
            onefetch
            hardinfo2
            imgcat
            nix-index
            ccze
            unar
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
    )
    ++ (with pkgs.nodePackages; [
      typescript-language-server
      vscode-json-languageserver
      node2nix
      markdownlint-cli2
      prettier
    ]);
}
