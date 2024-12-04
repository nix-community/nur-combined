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
    "L+ /home/${user}/.ssh/config - - - - ${config.vaultix.secrets.ssh-cfg.path}"
  ];
  programs = {

    ssh = {
      startAgent = true;
      enableAskPassword = true;
      askPassword = "${pkgs.wayprompt}/bin/wayprompt-ssh-askpass";
      # askPassword = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
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
      ${pkgs.atuin}/bin/atuin init fish | source
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
            (python311.withPackages (
              ps: with ps; [
                pandas
                requests
                absl-py
                tldextract
                bleak
                matplotlib
                clang
                pyyaml
              ]
            ))
          ];
          crypt = [
            openssl
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
              nix = inputs'.lix-module.packages.default;
            })
            vscode.fhs
            nodejs_latest.pkgs.pnpm
            nodejs_latest
            qemu-utils
            # rustup
            linuxPackages_latest.perf
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
              lldb
              # haskell-language-server
              gopls
              cmake-language-server
              zls
              android-file-transfer
              nixpkgs-review
              shfmt
            ]
            [
              vscode-langservers-extracted
              bash-language-server
            ]
            [
              # rust-analyzer
              # nil
              nixd
              nil
              shfmt
              nixfmt-rfc-style
              # taplo
              rustfmt
              clang-tools
              # haskell-language-server
              cmake-language-server
              arduino-language-server
              typst-lsp
              vhdl-ls
              delve
              python311Packages.python-lsp-server
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
            runwin
            guix-run
            runbkworm
            bkworm
            arch-run
            # ubt-rv-run
            #opulr-a-run
            lunar-run
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
            acpi
            swww
            distrobox
            dmidecode
            nix-output-monitor
            rustic

          ];
          info = [
            parallel-disk-usage # disk space info
            freshfetch
            htop
            onefetch
            hardinfo
            imgcat
            nix-index
            ccze
            unar
          ];
          bluetooth = [ bluetuith ];

          sound = [ pulseaudio ];

          display = [ cage ];

          cursor = [ graphite-cursors ];
        }
      )
    )
    ++ (with pkgs.nodePackages; [
      typescript-language-server
      node2nix
      markdownlint-cli2
      prettier
    ]);
}
