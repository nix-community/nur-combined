{
  config,
  lib,
  pkgs,
  homelab,
  inputs,
  system,
  ...
}:
let
  cfg = config.nixcfg.users;
  homePath =
    if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${cfg.toyvo.name}" else "/home/${cfg.toyvo.name}";
  # nixpkgs' cargo-bundle (needed to bundle Zed on macOS) fails to build:
  # cargo-setup-hook exports AWS_LC_SYS_USE_SYSTEM=1 but openssl is not
  # AWS-LC. Build the bundled copy with cmake instead.
  # TODO: drop once nixpkgs' cargo-bundle builds again.
  zed-editor-fixed = pkgs.zed-editor.override (
    lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      cargo-bundle = pkgs.cargo-bundle.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.cmake ];
        preBuild = (old.preBuild or "") + ''
          unset AWS_LC_SYS_USE_SYSTEM
        '';
        dontUseCmakeConfigure = true;
      });
    }
  );
  # herdr-desktop from nixpkgs ships a macOS bundle without
  # NSLocalNetworkUsageDescription, so macOS 15+ Local Network privacy
  # silently blocks its LAN connections (ssh: No route to host) and never
  # prompts. Inject the key and re-sign ad-hoc. This must run in postFixup:
  # fixupPhase strips binaries (invalidating any earlier signature) and runs
  # before installCheckPhase, so signing here covers the final bits and the
  # version check exercises the shipped signature. Linux is unaffected: the
  # appended postFixup is empty there, yielding an identical derivation.
  # TODO: drop once upstream herdrdev/herdr-app ships the key in its bundle
  # (nixpkgs picks it up automatically); then this becomes plain `herdr-desktop`.
  herdr-desktop-fixed = pkgs.herdr-desktop.overrideAttrs (old: {
    # zstd-sys finds libzstd via pkg-config under cargo-setup-hook, and the
    # nixpkgs package provides neither (Darwin has no pkg-config at all)
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.pkg-config ];
    buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.zstd ];
    postFixup =
      (old.postFixup or "")
      + lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
        app=$out/Applications/Herdr.app
        /usr/bin/plutil -insert NSLocalNetworkUsageDescription -string "Herdr connects to your machines over SSH on the local network." "$app/Contents/Info.plist" 2>/dev/null \
          || /usr/bin/plutil -replace NSLocalNetworkUsageDescription -string "Herdr connects to your machines over SSH on the local network." "$app/Contents/Info.plist"
        /usr/bin/codesign --force --deep --sign - "$app"
      '';
  });
  # herdr-core >= 0.1.16 honors `shell = [...]` in herdr-core/config.toml
  # (fish default shell); nixpkgs still ships 0.1.15.
  # TODO: drop once nixpkgs herdr-core reaches 0.1.16.
  herdr-core-0-1-16 = pkgs.herdr-core.overrideAttrs (old: rec {
    version = "0.1.16";
    src = pkgs.fetchFromGitHub {
      owner = "herdrdev";
      repo = "herdr-core";
      tag = "v${version}";
      fetchSubmodules = true;
      hash = "sha256-TIOXZswCum0g3qcDK+RDZb9Y7lUu+bx+Oyja4EtKKh4=";
    };
    cargoHash = "sha256-hMkych62liZ+Oe5huM2drN5/6ckpF8AEHH2dyskcivo=";
    # The hc_update_* distribution tests restart the core and wait at most
    # 5 s (hardcoded wait_for_socket timeout) for the new core. On a loaded
    # aarch64 builder (e.g. oracle building 500+ derivations) the restart
    # takes longer, failing with "core did not start within 5 s"
    # (2026-11-12: 4 passed, these 2 failed in 6.5 s). Same class as the two
    # network tests nixpkgs already skips for the sandbox.
    checkFlags = (old.checkFlags or [ ]) ++ [
      "--skip=hc_update_downloads_checks_and_swaps"
      "--skip=hc_update_to_a_version_takes_at_least_that_one"
    ];
    # vendor/ghostty is pinned to the same commit as 0.1.15
    # (1e5cdb865807abc990181efb8ebfa9122955cce2), so its Zig deps are
    # byte-identical: reuse the already-fetched output instead of
    # fetching again (fresh `zig fetch` can't init TLS on Darwin, and
    # the output is platform-independent anyway). Note: this must name
    # the original package's output; `old.zigDeps` here would already
    # point at the new src.
    zigDeps = pkgs.herdr-core.zigDeps;
  });

  # dioxus-cli 0.7.10's dependency tree enables zstd-sys's `pkg-config`
  # feature, whose build script hard-fails when system libzstd isn't
  # discoverable via pkg-config — but nixpkgs omits zstd from its
  # buildInputs (only libgit2 and openssl provide .pc files). Same shape
  # as nixpkgs sentry-cli, which does include zstd.
  # TODO: drop once upstream adds zstd to dioxus-cli's buildInputs.
  dioxus-cli-fixed = pkgs.dioxus-cli.overrideAttrs (old: {
    buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.zstd ];
  });

  shells = with pkgs; [
    bashInteractive
    fish
    nushell
    powershell
    zsh
  ];
  packages =
    with pkgs;
    shells
    ++ [
      age
      ast-grep
      bison
      broot
      bun
      cargo-generate
      cargo-make
      cargo-watch
      ccache
      cmake
      curl
      curlie
      deno
      dfu-util
      dig
      dioxus-cli-fixed
      doggo
      dotnet-sdk
      dotnet-sdk_8
      dust
      fd
      flex
      forgejo-cli
      gh
      gnugrep
      gnumake
      gnused
      gnutar
      gperf
      gping
      graphviz
      gzip
      helix
      herdr
      herdr-core-0-1-16
      httpie
      hyperfine
      icu
      inputs.nixcfg.packages.${system}.toyvo-neovim
      jq
      jujutsu
      just
      kubectl
      libffi
      libiconv
      libusb1
      lsof
      neovide
      netcat
      ninja
      nix-output-monitor
      nix-tree
      nixfmt
      nmap
      nodejs
      nvd
      openssh
      openssl
      pkg-config
      prettier
      procs
      proton-pass-cli
      python3
      rclone
      ripgrep
      rsync
      rustup
      sd
      secretspec
      sops
      sqlite
      systemfd
      tlrc
      tlrc
      unzip
      uutils-coreutils-noprefix
      uv
      volta
      wget
      xz
      yq
      zip
      zstd
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      aha
      clang
      clinfo
      fwupd
      gcc
      kexec-tools
      mesa-demos
      pciutils
      vulkan-tools
      wayland-utils
      yubico-piv-tool
      yubikey-manager
      yubikey-personalization
    ]
    ++ lib.optionals config.nixcfg.dev.enable [

    ];
  guiPackages =
    with pkgs;
    [
      element-desktop
      herdr-desktop-fixed
      inkscape
      podman-desktop
      zed-editor-fixed
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      appcleaner
      ghostty-bin
      inputs.nixcfg.packages.${system}.tinycast-beta
      libreoffice-bin
      pinentry_mac
      utm
    ]
    ++ lib.optionals (stdenv.hostPlatform.isLinux) [
      firefox
      ghostty
      gimp
      libreoffice
      proton-vpn
      yubioath-flutter
    ]
    ++ lib.optionals (stdenv.hostPlatform.system != "aarch64-linux") [
      proton-pass
      protonmail-desktop
    ];
in
{
  # `nixcfg.gui` is read below; `config.ids.*` is read under `isLinux`
  # guards only. nix-darwin has no `ids` option, so this module must NOT
  # import it — NixOS hosts importing this module must also import
  # `inputs.nixcfg.modules.nixos.ids`.
  options.nixcfg = {
    users.toyvo = {
      enable = lib.mkEnableOption "toyvo user";
      name = lib.mkOption {
        type = lib.types.str;
        default = "toyvo";
      };
    };
    dev.enable = lib.mkEnableOption "Development Programs to be available outside of a devshell";
    gui.enable = lib.mkEnableOption "GUI Applications" // {
      # macs will always have GUI enabled
      default = pkgs.stdenv.hostPlatform.isDarwin;
    };
  };

  config = lib.mkIf cfg.toyvo.enable {
    users = {
      users = {
        ${cfg.toyvo.name} = (
          lib.mkMerge [
            {
              name = cfg.toyvo.name;
              description = "Collin Diekvoss";
              home = homePath;
              shell = pkgs.fish;
              openssh.authorizedKeys.keys = [
                homelab.publicKeys."herdr_mobile_pixel10a_ed25519.pub"
                homelab.publicKeys."ssh_toyvo_auth_ed25519.pub"
                homelab.publicKeys."yubikey_usba_ed25519_sk.pub"
                homelab.publicKeys."yubikey_usbc_ed25519_sk.pub"
              ];
            }
            (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
              isNormalUser = true;
              extraGroups = [
                "networkmanager"
                "wheel"
                "input"
                "uinput"
                cfg.toyvo.name
              ]
              ++ lib.optionals (config.virtualisation.podman.enable or false) [ "podman" ];
              initialHashedPassword = "$y$j9T$tkZ4b5vK1fCsRP0oWUb0e1$w0QbUEv9swXir33ivvM70RYTYflQszeLBi3vubYTqd8";
              uid = config.ids.uids.toyvo;
            })
          ]
        );
      };
      groups.${cfg.toyvo.name} = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        gid = config.ids.gids.toyvo;
      };
    };
    nix.settings.trusted-users = [
      cfg.toyvo.name
    ];
    home-manager.users.${cfg.toyvo.name} = {
      home.username = cfg.toyvo.name;
      home.homeDirectory = homePath;
      nixcfg = {
        shells.enable = true;
        session.enable = true;
        sops-home.enable = true;
        gui.enable = config.nixcfg.gui.enable;
        users.toyvo.enable = true;
      };
    };

    virtualisation.podman.enable = config.nixcfg.dev.enable;

    programs = {
      zsh.enable = true;
      fish.enable = true;
    };
    environment = {
      inherit shells;
    };
    environment.systemPackages = packages ++ lib.optionals config.nixcfg.gui.enable guiPackages;
    fonts.packages = with pkgs; [
      monaspace
      nerd-fonts.monaspace
      nerd-fonts.symbols-only
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      noto-fonts-emoji-blob-bin
      noto-fonts-lgc-plus
      noto-fonts-monochrome-emoji
    ];
  };
}
