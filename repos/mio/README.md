# nurpkgs

see all packages: <https://nur.nix-community.org/repos/mio/> How to use (NUR guide) <https://nur.nix-community.org/documentation/> You will want to use `nur.repos.mio.*`

Some packages are fully broken or mostly broken. Some packages are deprecated without a clear marking. I am not putting efforts to maintain this package collections to a quality that is ready to support other users beyond my personal usage.

+ linux: x86_64-v3, aarch64
+ darwin: aarch64

To use modules: (Note that system isn't defined by default in some contexts. You could define it or replace it with a constant like `x86_64-linux`)

```nix
  imports = [
    inputs.nur.legacyPackages."${system}".repos.mio.modules.zfs-impermanence-on-shutdown
  ];
```

Toshy: NixOS module `modules.toshy` (udev, uinput, `input` group — required for the keymapper unless you already provide those) plus Home Manager module `modules.toshy-hm` (runtime + user files + systemd user services). Do not import `toshy-hm` into a NixOS `imports` list.

```nix
# NixOS
imports = [ inputs.mio.legacyPackages.${system}.modules.toshy ];
services.toshy = { enable = true; users = [ "yourname" ]; };

# Home Manager
imports = [ inputs.mio.legacyPackages.${system}.modules.toshy-hm ];
services.toshy.enable = true;
```

Use without nur: add to flake.nix inputs

```

    mio = {
      url = "git+https://github.com/mio-19/nurpkgs.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
```

Some packages are only available without nur as they failed to evaluate under nur constraints (no IFD): while update works, document needs no-ifd <https://github.com/nix-community/NUR/issues/1020#issuecomment-5134383935>

+ gifcurry
+ prospect-mail
+ line
+ notepad-plus-plus
+ adobe-acrobat-reader
+ insta360-studio
+ rclone-browser (qt6)
+ supertuxkart-evolution

```
inputs.mio.packages.${pkgs.stdenv.hostPlatform.system}.downkyicore
pkgs.nur.repos.mio.downkyicore

inputs.mio.legacyPackages."${system}".modules.howdy
inputs.nur.legacyPackages."${system}".repos.mio.modules.howdy
```

## cache

binary cache is provided as best effort. binary cache is frequently *NOT* up to date and you will frequently have to build packages from source code because github actions is often not sufficient to compile packages. Solutions to provide up to date binary cache do require money every month

```nix
  nix = {
    settings = {
      substituters = [
        "https://mio.cachix.org/"
      ];
      trusted-public-keys = [
        "mio.cachix.org-1:FlupyyLPURqwdRqtPT/LBWKsXY7JKsDkzZQo2K6LeMM="
      ];
    };
  };
```

```zsh
--option 'extra-substituters' 'https://mio.cachix.org/' --option extra-trusted-public-keys "mio.cachix.org-1:FlupyyLPURqwdRqtPT/LBWKsXY7JKsDkzZQo2K6LeMM="
```

## sources - where files were copied from

files are copied from following locations. some are modified in this repo and some are not.

+ zsh-patina <https://github.com/NixOS/nixpkgs/pull/530825/changes>
+ minetest591 - from nixos-24.11 commit 50ab793786d9de88ee30ec4e4c24fb4236fc2674 <https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/games/minetest/default.nix>
+ minetest580 & irrlichtmt - parent of <https://github.com/NixOS/nixpkgs/commit/d61c03fe460f6349e5173e007fb2b678c33bed36> commit 33c8b1a7202d4c22d74f4db73666e9a868069d2c
+ wireguird <https://discourse.nixos.org/t/go-version-error-requires-go1-17-or-later/69176/4>
+ shared folder, zfs-impermanence-on-shutdown.nix <https://github.com/chaotic-cx/nyx/commit/39b1da91e4344890e38f406f64e3e0d5731c5e5f>
+ betterbird package — <https://github.com/NixOS/nixpkgs/pull/528210> (PR commit 64438b57119d6895698b2bbf5f7d0479c3f26de8); version/source hashes updated locally since then
+ brave-origin (`by-name/br/brave-origin/`) — repackaged as reproducible source materialization using nixpkgs `gclient2nix` conventions (`source-lock.json` + `gclient-deps.json`) with updater workflow in `update.sh`
+ buildMozillaMach (`by-name/bu/buildMozillaMach/`) — copied from nixpkgs commit [a2a125b55a76e59cd23f5784fd0c790206070953](https://github.com/NixOS/nixpkgs/tree/a2a125b55a76e59cd23f5784fd0c790206070953/pkgs/build-support/build-mozilla-mach) (`pkgs/build-support/build-mozilla-mach/default.nix` + patches), plus PR #528210 (`finalBinaryName`, `withWasiSysroot`, `extraPreConfigure`) and local Betterbird install-path `finalBinaryName` patch (<https://github.com/mio-19/nurpkgs/commit/20876484d4e71203aaa00519e11ca8b1a4a80861>)
+ wrapFirefox (`by-name/wr/wrapFirefox/`) — copied from nixpkgs commit [421eebfd0ec7bccd4abe826ce62d7e6e83129493](https://github.com/NixOS/nixpkgs/tree/421eebfd0ec7bccd4abe826ce62d7e6e83129493/pkgs/applications/networking/browsers/firefox/wrapper.nix), plus PR #528210 `isMail` flag (desktop metadata no longer keyed off `libName` prefix `thunderbird`)
+ wrapThunderbird (`by-name/wr/wrapThunderbird/`) — copied from nixpkgs commit [421eebfd0ec7bccd4abe826ce62d7e6e83129493](https://github.com/NixOS/nixpkgs/tree/421eebfd0ec7bccd4abe826ce62d7e6e83129493/pkgs/applications/networking/mailreaders/thunderbird/wrapper.nix), plus PR #528210 `isMail = true`
+ beammp-launcher nixpkgs commit 68990df0529b74cde8b63cd1d5f5f5550e630a0c
+ cacert_3108 <https://github.com/NixOS/nixpkgs/blob/9a9ab6b9242c4526f04abeeef99b8de1d7af1fea/pkgs/data/misc/cacert/default.nix>
+ <https://github.com/emmanuelrosa/erosanix/tree/master/pkgs/mkwindowsapp> commit 464f070d952afff764d82041d371cfee3e689d2a mkwindowsapp mkwindowsapp-tools line.nix hooks lib pkgs/wineshell
+ android-translation-layer (`by-name/an/android-translation-layer/`) — nixpkgs commit 104240a772428cc2e20d8fd86c9ddbb886bbaff2 (then updated to latest upstream)
+ bionic-translation (`by-name/bi/bionic-translation/`) — nixpkgs commit 104240a772428cc2e20d8fd86c9ddbb886bbaff2 (then updated to latest upstream)
+ art-standalone (`by-name/ar/art-standalone/`) — nixpkgs commit 104240a772428cc2e20d8fd86c9ddbb886bbaff2 (then updated to latest upstream)
+ local-ai nixpkgs commit 7377f649a8671844d42dde9ea739961f06ce7edf
+ <https://github.com/maydayv7/dotfiles/raw/refs/heads/stable/packages/wine/notepad++.nix>
+ rclone-ui nixpkgs commit df70bd515ec9175798339adf2ae6a22052d86577
+ pkgs/games/stuntrally/ nixpkgs commit 249e5cbb33fb2ba40ba49cf4ef4bd4c240503516
+ a9ac63c96516b5c14658a14a04fdb1248529d01b nix-output-monitor
+ polkit nixpkgs 88d3861acdd3d2f0e361767018218e51810df8a1
+ darling nixpkgs commit 01b6610eb0c98ee6d840e0d060cb41e334879f65^ 31bdcff5843e30d33eb758334435298a571bd2af^ <https://github.com/NixOS/nixpkgs/commit/31bdcff5843e30d33eb758334435298a571bd2af>
+ widevine-firefox <https://github.com/ToborWinner/teanyth/blob/263decae003ec1b7ed0f7cde30b57c6f2f320c0e/pkgs/firefox-widevine.nix#L4>
+ fdroidcl_git - copied from nixpkgs and updated to <https://github.com/Hoverth/fdroidcl/commit/d870160f16a22836d13f59acdabcd70709c68db6>


+ versionCheckHomeHook <https://github.com/numtide/llm-agents.nix/tree/main/packages/versionCheckHomeHook> commit 04df876de28f0684a0d7110444d7f64da5c14d17
+ ryubing - copied from nixpkgs commit [9b50d450945903abb6fb7933c6cfd8f483f0dc2d](https://github.com/NixOS/nixpkgs/tree/9b50d450945903abb6fb7933c6cfd8f483f0dc2d) and modified to copy the desktop/icon files on Darwin to allow `desktopToDarwinBundle` to generate a macOS application bundle.
+ telegram-desktop_682 nixpkgs 8dc49b8b206a683d1f6605e0fd993c0f5d49c98d
+ jetbrains_idea-oss — IntelliJ IDEA Community built from JetBrains `idea/2026.2.1`
+ qq_bwrap - adapted from linuxqq-nt-bwrap https://aur.archlinux.org/packages/linuxqq-nt-bwrap
+ wechat_bwrap - adapted from AUR package wechat-universal-bwrap (https://aur.archlinux.org/packages/wechat-universal-bwrap) by 7Ji, leaeasy, and devome
+ gcenx-wine-staging / gcenx-wine-devel / gcenx-wine-stable — packaging adapted from [nobbmaestro/wine-stable-nix](https://github.com/nobbmaestro/wine-stable-nix); prebuilt Wine.app binaries from [Gcenx/macOS_Wine_builds](https://github.com/Gcenx/macOS_Wine_builds). Prefixed `gcenx-` to distinguish from nixpkgs `wine*` (Linux source builds; Darwin unsupported on nixpkgs-unstable).
+ swift6-jen20 (Swift 6.2.4) — base from [reckenrode/nixpkgs `swift-update-mk2`](https://github.com/reckenrode/nixpkgs/tree/swift-update-mk2) commit [9bd6cfed336853908d93c95c21f39e0255ac409c](https://github.com/reckenrode/nixpkgs/commit/9bd6cfed336853908d93c95c21f39e0255ac409c) (`pkgs/development/compilers/swiftPackages`, `pkgs/top-level/swift-packages.nix`, plus `hostPlatform.swift` from `lib/systems/default.nix`); Linux REPL/cxx/sysroot fixes from [jen20 gist](https://gist.github.com/jen20/3b797f020ee81dc564e768f1670ced90); C++ interop / `swiftrt.o` `llc -relocation-model=pic` from Randy Eckenrode’s Matrix/`swift-update-mk2` approach (local PIC + `swiftrt` conversion for Linux PIE links); related REPL test notes from [booxter/nixpkgs `fix-swift-repl`](https://github.com/booxter/nixpkgs/commits/fix-swift-repl/). Linux ICU: vendored reckenrode mk2 `pkgs/os-specific/darwin/by-name/ic/ICU` (`by-name/sw/swift6-jen20/ICU`). Local `0011-link-clangBasic-from-swiftBasic.patch` for external-Clang `DarwinSDKInfo` link. Details: `by-name/sw/swift6-jen20/README.md`

## todo - reading

+ <https://github.com/NixOS/nixpkgs/issues/171182#issuecomment-2467081726>

## llm policy

headache. use LLM for boring no brain task

## Python 3.8

While Python 3.8 reached End-Of-Life in October 2024 and is removed from modern NixOS releases, we dynamically fetch the `nixos-23.05` legacy channel inside `beam-studio`'s backend build (`by-name/beam-studio/backend.nix`). This provides a complete Python 3.8 environment and old `opencv-python` wheels necessary to correctly execute the proprietary, decompiled PyInstaller `.pyc` bytecode blobs (`beamify`, `fluxclient`, `fluxsvg`) that `beam-studio` relies on without needing to maintain the outdated Python version globally.

## Vendored Packages

* `wolfssl`: Copied from Nixpkgs commit `3040774c2f99756cc03c28dd78bbcb2bbd4e73f9` (the revision immediately before it was dropped from the tree), to support JNI for `art-standalone_patched`.
* `python27`: Copied from Nixpkgs commit `55280fa56481cd71b53545171eb9ec5ab44c3795` (the revision immediately before cpython 2.7 and its helpers were moved to resholve and subsequently removed from the top-level). It was removed in commit `e6871d9800efed3395535a879e323b546d96feab` (PR #516241). Details: `by-name/py/python27/README.md`.
