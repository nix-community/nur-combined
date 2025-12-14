# please put certain same name packages in default.nix to avoid accident overrides or infinite recursion

{
  pkgs ? import <nixpkgs> {
    #config.permittedInsecurePackages = [
    #  "qtwebengine-5.15.19"
    #];
    config.allowUnfree = true;
  },
}:
with (import ./private.nix { inherit pkgs; });
rec {
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
  minetest580 = pkgs.callPackage ./pkgs/minetest580 {
    irrlichtmt = pkgs.callPackage ./pkgs/irrlichtmt {
      stdenv = v3Optimizations pkgs.clangStdenv;
    };
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
  /*
    # https://github.com/musescore/MuseScore/pull/21874
    # https://github.com/adazem009/MuseScore/tree/piano_keyboard_playing_notes
    # broken on nixpkgs between a98f368960a921d4fdc048e3a2401d12739bc1f9 and 7fd9583d8c174ecc7ac0094bed29bde80135c876
    # broken by qt 6.10.0 -> 6.10.1 update
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
  */
  # https://github.com/musescore/MuseScore/pull/28073
  # https://github.com/githubwbp1988/MuseScore/tree/alex
  musescore-alex = v3override (
    pkgs.musescore.overrideAttrs (old: {
      version = "4.6.3-alex-unstable-20251121";
      src = pkgs.fetchFromGitHub {
        owner = "githubwbp1988";
        repo = "MuseScore";
        rev = "725f94a55db85a9bf71602fd2e452c1475351782";
        hash = "sha256-0PWMRq4MZEkq1kwWEQ+DBPIWByaXU/DcZ7wE12mQTEM=";
      };
      patches = [ ];
    })
  );
  tuxguitar = v3overrideAttrs (
    pkgs.callPackage ./pkgs/tuxguitar/package.nix {
      swt = v3overrideAttrs (pkgs.callPackage ./pkgs/swt/package.nix { });
    }
  );
  nss_git = callOverride ./pkgs/nss-git { };
  #aria2-wrapped = pkgs.writeShellScriptBin "aria2" ''
  #  ${pkgs.aria2}/bin/aria2c -s65536 -j65536 -x16 -k1M "$@"
  #'';
  # audacity4 = nodarwin (pkgs.qt6Packages.callPackage ./pkgs/audacity4/package.nix { });
  cb = pkgs.callPackage ./pkgs/cb { };
  jellyfin-media-player = v3override (
    pkgs.kdePackages.callPackage ./pkgs/jellyfin-media-player {
      mpvqt = pkgs.kdePackages.mpvqt.overrideAttrs (old: {
        meta = old.meta // {
          platforms = pkgs.lib.platforms.unix;
        };

        propagatedBuildInputs = map (
          pkg:
          pkg.overrideAttrs (oldPkg: {
            meta = (oldPkg.meta or { }) // {
              platforms = pkgs.lib.platforms.unix;
            };
          })
        ) old.propagatedBuildInputs;
      });
    }
  );
  mdbook-generate-summary = v3overrideAttrs (pkgs.callPackage ./pkgs/mdbook-generate-summary { });
  beammp-launcher = pkgs.callPackage ./pkgs/beammp-launcher/package.nix {
    cacert_3108 = pkgs.callPackage ./pkgs/cacert_3108 { };
  };
  beammp-server = pkgs.callPackage ./pkgs/beammp-server/package.nix { };
  firefox_nightly-unwrapped = v3override (
    v3overrideAttrs (
      pkgs.callPackage ./pkgs/firefox-nightly {
        nss_git = nss_git;
        nyxUtils = nyxUtils;
        icu78 = icu.icu78;
      }
    )
  );

  firefox_nightly = pkgs.wrapFirefox firefox_nightly-unwrapped { };
  betterbird-unwrapped = v3overrideAttrs (pkgs.callPackage ./pkgs/betterbird { });
  betterbird = pkgs.wrapThunderbird betterbird-unwrapped {
    applicationName = "betterbird";
    libName = "betterbird";
  };

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

  howdy = nodarwin (pkgs.callPackage ./pkgs/howdy/package.nix { });
  linux-enable-ir-emitter = nodarwin (
    pkgs.callPackage ./pkgs/linux-enable-ir-emitter/package.nix { }
  );

  proton-cachyos = pkgs.callPackage ./pkgs/proton-bin {
    toolTitle = "Proton-CachyOS";
    tarballPrefix = "proton-";
    tarballSuffix = "-x86_64.tar.xz";
    toolPattern = "proton-cachyos-.*";
    releasePrefix = "cachyos-";
    releaseSuffix = "-slr";
    versionFilename = "cachyos-version.json";
    owner = "CachyOS";
    repo = "proton-cachyos";
  };

  proton-cachyos_x86_64_v2 = proton-cachyos.override {
    toolTitle = "Proton-CachyOS x86-64-v2";
    tarballSuffix = "-x86_64_v2.tar.xz";
    versionFilename = "cachyos-v2-version.json";
  };

  proton-cachyos_x86_64_v3 = proton-cachyos.override {
    toolTitle = "Proton-CachyOS x86-64-v3";
    tarballSuffix = "-x86_64_v3.tar.xz";
    versionFilename = "cachyos-v3-version.json";
  };

  proton-cachyos_x86_64_v4 = proton-cachyos.override {
    toolTitle = "Proton-CachyOS x86-64-v4";
    tarballSuffix = "-x86_64_v4.tar.xz";
    versionFilename = "cachyos-v4-version.json";
  };

  proton-cachyos_nightly_x86_64_v3 = proton-cachyos.override {
    toolTitle = "Proton-CachyOS Nightly x86-64-v3";
    tarballSuffix = "-x86_64_v3.tar.xz";
    url = "https://nightly.link/CachyOS/proton-cachyos/actions/runs/19506926176/proton-cachyos-10.0-20251112-base-131-g471736d4-x86_64_v3.tar.xz.zip";
    version = {
      base = "10.0";
      release = "20251112";
      hash = "sha256-3wkekFESoLgVYdCvMSEWL6nBRytsScUrwpn7zzNLqYE=";
    };
    withUpdateScript = false;
  };

  proton-cachyos_nightly_x86_64_v4 = proton-cachyos.override {
    toolTitle = "Proton-CachyOS Nightly x86-64-v4";
    tarballSuffix = "-x86_64_v4.tar.xz";
    url = "https://nightly.link/CachyOS/proton-cachyos/actions/runs/19506926176/proton-cachyos-10.0-20251112-base-131-g471736d4-x86_64_v4.tar.xz.zip";
    version = {
      base = "10.0";
      release = "20251112";
      hash = "sha256-0dmK5HnFyN/V1aicCkRiubVkAtW1X1XJZTVljhuWn1w=";
    };
    withUpdateScript = false;
  };

  proton-ge-custom = pkgs.callPackage ./pkgs/proton-bin {
    toolTitle = "Proton-GE";
    tarballSuffix = ".tar.gz";
    toolPattern = "GE-Proton.*";
    releasePrefix = "GE-Proton";
    releaseSuffix = "";
    versionFilename = "ge-version.json";
    owner = "GloriousEggroll";
    repo = "proton-ge-custom";
  };
  linux_cachyos = drvDropUpdateScript cachyosPackages.cachyos-gcc.kernel;
  linux_cachyos-lto = drvDropUpdateScript cachyosPackages.cachyos-lto.kernel;
  linux_cachyos-lto-znver4 = drvDropUpdateScript cachyosPackages.cachyos-lto-znver4.kernel;
  linux_cachyos-gcc = drvDropUpdateScript cachyosPackages.cachyos-gcc.kernel;
  linux_cachyos-server = drvDropUpdateScript cachyosPackages.cachyos-server.kernel;
  linux_cachyos-hardened = drvDropUpdateScript cachyosPackages.cachyos-hardened.kernel;
  linux_cachyos-rc = cachyosPackages.cachyos-rc.kernel;
  linux_cachyos-lts = cachyosPackages.cachyos-lts.kernel;

  linuxPackages_cachyos = cachyosPackages.cachyos-gcc;
  linuxPackages_cachyos-lto = cachyosPackages.cachyos-lto;
  linuxPackages_cachyos-lto-znver4 = cachyosPackages.cachyos-lto-znver4;
  linuxPackages_cachyos-gcc = cachyosPackages.cachyos-gcc;
  linuxPackages_cachyos-server = cachyosPackages.cachyos-server;
  linuxPackages_cachyos-hardened = cachyosPackages.cachyos-hardened;
  linuxPackages_cachyos-rc = cachyosPackages.cachyos-rc;
  linuxPackages_cachyos-lts = cachyosPackages.cachyos-lts;

  # the commit before https://github.com/NixOS/nixpkgs/commit/2dbc1128b3d1b2a80eb62607bf21f0f94f9b2d5f
  zfs-latestCompatibleLinuxPackages = lib.pipe pkgs.linuxKernel.packages [
    builtins.attrValues
    (builtins.filter (
      kPkgs:
      (builtins.tryEval kPkgs).success
      && kPkgs ? kernel
      && kPkgs.kernel.pname == "linux"
      && kPkgs.${pkgs.zfs.kernelModuleAttribute}.meta.broken != true
    ))
    (builtins.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)))
    lib.last
  ];
  zfs_unstable-latestCompatibleLinuxPackages = lib.pipe pkgs.linuxKernel.packages [
    builtins.attrValues
    (builtins.filter (
      kPkgs:
      (builtins.tryEval kPkgs).success
      && kPkgs ? kernel
      && kPkgs.kernel.pname == "linux"
      && kPkgs.${pkgs.zfs_unstable.kernelModuleAttribute}.meta.broken != true
    ))
    (builtins.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)))
    lib.last
  ];
}
