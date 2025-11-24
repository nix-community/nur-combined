# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> {
    #config.permittedInsecurePackages = [
    #  "qtwebengine-5.15.19"
    #];
    config.allowUnfree = true;
  },
}:
let
  stdenv = pkgs.stdenv;
  fixcmake =
    x:
    x.overrideAttrs (old: {
      cmakeFlags = (old.cmakeFlags or [ ]) ++ [
        "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
      ];
    });
  v3Optimizations =
    if pkgs.stdenv.hostPlatform.isx86_64 then
      pkgs.stdenvAdapters.withCFlags [
        "-march=x86-64-v3"
        "-mtune=raptorlake"
      ]
    else
      stdenv: stdenv;
  v3overrideAttrs =
    if pkgs.stdenv.hostPlatform.isx86_64 then
      x:
      x.overrideAttrs (old: {
        env.NIX_CFLAGS_COMPILE = "-march=x86-64-v3 -mtune=raptorlake";
        env.RUSTFLAGS = "-C target_cpu=x86-64-v3";
      })
    else
      x: x;
  goV3OverrideAttrs =
    if pkgs.stdenv.hostPlatform.isx86_64 then
      x:
      x.overrideAttrs (old: {
        GOAMD64 = "v3";
      })
    else
      x: x;
  v3override =
    if pkgs.stdenv.hostPlatform.isx86_64 then
      x:
      x.override (prev: {
        stdenv = v3Optimizations pkgs.clangStdenv;
      })
    else
      x:
      x.override (prev: {
        stdenv = pkgs.clangStdenv;
      });
  v3overridegcc =
    if pkgs.stdenv.hostPlatform.isx86_64 then
      x:
      x.override (prev: {
        stdenv = v3Optimizations prev.stdenv;
      })
    else
      x: x;
  nodarwin =
    x:
    x.overrideAttrs (old: {
      meta = old.meta // {
        broken = pkgs.stdenv.hostPlatform.isDarwin;
      };
    });
  x8664linux =
    x:
    x.overrideAttrs (old: {
      meta = old.meta // {
        broken = !pkgs.stdenv.hostPlatform.isLinux || !pkgs.stdenv.hostPlatform.isx86_64;
      };
    });
  wip =
    x:
    x.overrideAttrs (old: {
      meta = old.meta // {
        broken = true;
      };
    });
  #  from chaotic-nyx
  nyxUtils = import ./shared/utils.nix {
    lib = pkgs.lib;
    nyxOverlay = null;
  };
  #  from chaotic-nyx
  callOverride =
    path: attrs:
    with pkgs;
    import path (
      {
        final = pkgs;
        prev = pkgs;
        inherit
          flakes
          nyxUtils
          gitOverride
          rustPlatform_latest
          ;
      }
      // attrs
    );

  #  from chaotic-nyx
  gitOverride =
    with pkgs;
    import ./shared/git-override.nix {
      inherit (pkgs)
        lib
        callPackage
        fetchFromGitHub
        fetchFromGitLab
        fetchFromGitea
        ;
      inherit (pkgs.rustPlatform) fetchCargoVendor;
      nyx = ./.;
      fetchRevFromGitHub = pkgs.callPackage ./shared/github-rev-fetcher.nix { };
      fetchRevFromGitLab = pkgs.callPackage ./shared/gitlab-rev-fetcher.nix { };
      fetchRevFromGitea = pkgs.callPackage ./shared/gitea-rev-fetcher.nix { };
    };
in
rec {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  telegram-desktop = pkgs.telegram-desktop.overrideAttrs (old: {
    unwrapped = v3overridegcc (
      old.unwrapped.overrideAttrs (old2: {
        # see https://github.com/Layerex/telegram-desktop-patches
        patches = (pkgs.telegram-desktop.unwrapped.patches or [ ]) ++ [
          ./patches/0001-telegramPatches.patch
        ];
      })
    );
  });
  materialgram = pkgs.materialgram.overrideAttrs (old: {
    unwrapped = v3overridegcc (
      old.unwrapped.overrideAttrs (old2: {
        # see https://github.com/Layerex/telegram-desktop-patches
        patches = (pkgs.materialgram.unwrapped.patches or [ ]) ++ [
          ./patches/0001-materialgramPatches.patch
        ];
      })
    );
  });
  openssh = v3override (
    (pkgs.openssh_10_2 or pkgs.openssh).overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./patches/openssh.patch ];
      #doCheck = false;
    })
  );
  openssh_hpn = v3override (
    pkgs.openssh_hpn.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./patches/openssh.patch ];
    })
  );
  grub2 = nodarwin (
    v3overridegcc (
      pkgs.grub2.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./patches/grub-os-prober-title.patch ];
      })
    )
  );
  bees = nodarwin (v3overridegcc pkgs.bees);
  wireguird = goV3OverrideAttrs (pkgs.callPackage ./pkgs/wireguird { });
  lmms = pkgs.callPackage ./pkgs/lmms/package.nix {
    withOptionals = true;
    stdenv = v3Optimizations pkgs.clangStdenv;
  };
  minetest591 = pkgs.callPackage ./pkgs/minetest591 {
    stdenv = v3Optimizations pkgs.clangStdenv;
  };
  minetest591client = minetest591.override { buildServer = false; };
  minetest591server = minetest591.override { buildClient = false; };
  irrlichtmt = pkgs.callPackage ./pkgs/irrlichtmt {
    stdenv = v3Optimizations pkgs.clangStdenv;
  };
  minetest580 = pkgs.callPackage ./pkgs/minetest580 {
    irrlichtmt = irrlichtmt;
    stdenv = v3Optimizations pkgs.clangStdenv;
  };
  minetest580client = minetest580.override { buildServer = false; };
  minetest580-touch = minetest580.override {
    buildServer = false;
    withTouchSupport = true;
  };
  minetest580server = minetest580.override { buildClient = false; };
  musescore3 =
    if pkgs.stdenv.isDarwin then
      pkgs.callPackage ./pkgs/musescore3/darwin.nix { }
    else
      v3overrideAttrs (pkgs.libsForQt5.callPackage ./pkgs/musescore3 { });
  # https://github.com/musescore/MuseScore/pull/21874
  # https://github.com/adazem009/MuseScore/tree/piano_keyboard_playing_notes
  # broken on nixpkgs between a98f368960a921d4fdc048e3a2401d12739bc1f9 and 7fd9583d8c174ecc7ac0094bed29bde80135c876
  # https://github.com/NixOS/nixpkgs/compare/a98f368960a921d4fdc048e3a2401d12739bc1f9%E2%80%A67fd9583d8c174ecc7ac0094bed29bde80135c876
  musescore-adazem009 = v3override (
    pkgs.musescore.overrideAttrs (old: {
      version = "4.4.0-piano_keyboard_playing_notes";
      src = pkgs.fetchFromGitHub {
        owner = "adazem009";
        repo = "MuseScore";
        rev = "e3de9347f6078f170ddbfa6dcb922f72bb7fef88";
        hash = "sha256-1HvwkolmKa317ozprLEpo6v/aNX75sEdaXHlt5Cj6NA=";
      };
      patches = [ ./patches/piano_keyboard_playing_notes.patch ];
    })
  );
  # https://github.com/musescore/MuseScore/pull/28073
  # https://github.com/githubwbp1988/MuseScore/tree/alex
  musescore-alex = v3override (
    pkgs.musescore.overrideAttrs (old: {
      version = "4.6.3-alex-unstable-20251031";
      src = pkgs.fetchFromGitHub {
        owner = "githubwbp1988";
        repo = "MuseScore";
        rev = "487ee2105064f8571f95eb31f03cbf1687e96204";
        hash = "sha256-r2HjHKnO6pD+urrW57z/SPcgm4vSkAMvW4ZJH+c7J4M=";
      };
      patches = [ ];
    })
  );
  swt = (pkgs.callPackage ./pkgs/swt/package.nix { });
  tuxguitar = v3overrideAttrs (pkgs.callPackage ./pkgs/tuxguitar/package.nix { swt = swt; });
  aria2 = v3override (
    pkgs.aria2.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        (pkgs.fetchpatch {
          name = "fix patch aria2 fast.patch";
          url = "https://github.com/agalwood/aria2/commit/baf6f1d02f7f8b81cd45578585bdf1152d81f75f.patch";
          sha256 = "sha256-bLGaVJoHuQk9vCbBg2BOG79swJhU/qHgdkmYJNr7rIQ=";
        })
      ];
    })
  );
  aria2-wrapped = pkgs.writeShellScriptBin "aria2" ''
    ${aria2}/bin/aria2c -s65536 -j65536 -x256 -k1k "$@"
  '';
  #aria2-wrapped = pkgs.writeShellScriptBin "aria2" ''
  #  ${pkgs.aria2}/bin/aria2c -s65536 -j65536 -x16 -k1M "$@"
  #'';
  # audacity4 = nodarwin (pkgs.qt6Packages.callPackage ./pkgs/audacity4/package.nix { });
  cb = pkgs.callPackage ./pkgs/cb { };
  jellyfin-media-player = v3override (pkgs.qt6Packages.callPackage ./pkgs/jellyfin-media-player { });
  cacert_3108 = pkgs.callPackage ./pkgs/cacert_3108 { };
  mdbook-generate-summary = v3overrideAttrs (pkgs.callPackage ./pkgs/mdbook-generate-summary { });
  beammp-launcher = pkgs.callPackage ./pkgs/beammp-launcher/package.nix {
    cacert_3108 = cacert_3108;
  };
  caddy =
    let
      # Table mapping caddy source hash + Go version to plugins hash
      # Key format: "<srcHash>:<goVersion>"
      # To check current key: nix eval --impure --expr 'let pkgs = import <nixpkgs> {}; in "${pkgs.caddy.src.outputHash}:${pkgs.caddy.passthru.go.version}"' --raw
      # From local nixpkgs repo: nix eval --impure --expr 'let pkgs = import ./. {}; in "${pkgs.caddy.src.outputHash}:${pkgs.caddy.passthru.go.version}"' --raw
      caddyPluginsHashTable = {
        # nixpkgs-unstable 2025-11-04
        "sha256-KvikafRYPFZ0xCXqDdji1rxlkThEDEOHycK8GP5e8vk=:1.25.2" =
          "sha256-+3itNp/as78n584eDu9byUvH5LQmEsFrX3ELrVjWmEw=";
        # staging-next 20251107
        "sha256-KvikafRYPFZ0xCXqDdji1rxlkThEDEOHycK8GP5e8vk=:1.25.3" =
          "sha256-hfIP97+TKcQkGg6s19VQcz9bS1wqzSBtqVTbtDc4HSQ=";
        # release-25.05 20251107
        "sha256-hzDd2BNTZzjwqhc/STbSAHnNlP7g1cFuMehqU1LumQE=:1.24.9" =
          "sha256-lraVVvjqWpQJmlHhpfWZwC9S0Gvx7nQR6Nzmt0oEOLw=";
        # staging-next 20251116
        "sha256-KvikafRYPFZ0xCXqDdji1rxlkThEDEOHycK8GP5e8vk=:1.25.4" =
          "sha256-cZLVVKeEoSO4im0wGJfwzpAknPs2WFFJpTtDMcaGwhk=";
      };
      srcHash = pkgs.caddy.src.outputHash;
      goVersion = pkgs.caddy.passthru.go.version;
      lookupKey = "${srcHash}:${goVersion}";
      pluginsHash =
        caddyPluginsHashTable.${lookupKey}
          or (throw "Unknown caddy source hash + Go version: ${lookupKey}. Please update caddyPluginsHashTable in default.nix");
    in
    (goV3OverrideAttrs pkgs.caddy).withPlugins {
      # https://github.com/crowdsecurity/example-docker-compose/blob/main/caddy/Dockerfile
      # https://github.com/NixOS/nixpkgs/pull/358586
      plugins = [
        "github.com/caddy-dns/cloudflare@v0.2.2"
        "github.com/porech/caddy-maxmind-geolocation@v1.0.1"
        # "github.com/hslatman/caddy-crowdsec-bouncer/http@main"
      ];
      hash = pluginsHash;
    };
  /*
    firefox-unwrapped_nightly = (
      v3override (
        v3overrideAttrs (
          pkgs.callPackage ./pkgs/firefox-nightly {
            nss_git = nss_git;
            nyxUtils = nyxUtils;
          }
        )
      )
    );
      firefox_nightly = (pkgs.wrapFirefox firefox-unwrapped_nightly { });
      nss_git = callOverride ./pkgs/nss-git { };
  */
  betterbird-unwrapped = v3overrideAttrs (pkgs.callPackage ./pkgs/betterbird { });
  betterbird = pkgs.wrapThunderbird betterbird-unwrapped {
    applicationName = "betterbird";
    libName = "betterbird";
  };
  # https://github.com/NixOS/nixpkgs/pull/461412
  shell-gpt = pkgs.callPackage ./pkgs/shell-gpt/package.nix { };

  /*
    mygui-next = x8664linux (
      fixcmake (
        pkgs.callPackage ./pkgs/mygui-next/package.nix {
        }
      )
    );
    ogre-next_3 = x8664linux (
      v3overrideAttrs (pkgs.callPackage ./pkgs/ogre-next/default.nix { }).ogre-next_3
    );
    stuntrally3 = wip (
      pkgs.callPackage ./pkgs/stuntrally3 {
        ogre-next_3 = ogre-next_3;
        mygui = mygui-next;
      }
    );
  */
  speed_dreams = nodarwin (pkgs.callPackage ./pkgs/speed-dreams { });
  netdata = (v3override (goV3OverrideAttrs pkgs.netdata)).override { withCloudUi = true; };
}
