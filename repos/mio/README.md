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

Use without nur: add to flake.nix inputs

```

    mio = {
      url = "git+https://github.com/mio-19/nurpkgs.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
```

Some packages are only available without nur as they failed to evaluate under nur constraints:

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

a binary cache may or may not be available on Garnix. See <https://garnix.io/docs/caching/>

## sources - where files were copied from

files are copied from following locations. some are modified in this repo and some are not.

+ lmms - <https://github.com/NixOS/nixpkgs/pull/377643>
+ minetest591 - from nixos-24.11 commit 50ab793786d9de88ee30ec4e4c24fb4236fc2674 <https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/games/minetest/default.nix>
+ minetest580 & irrlichtmt - parent of <https://github.com/NixOS/nixpkgs/commit/d61c03fe460f6349e5173e007fb2b678c33bed36> commit 33c8b1a7202d4c22d74f4db73666e9a868069d2c
+ wireguird <https://discourse.nixos.org/t/go-version-error-requires-go1-17-or-later/69176/4>
+ shared folder, zfs-impermanence-on-shutdown.nix <https://github.com/chaotic-cx/nyx/commit/aacb796ccd42be1555196c20013b9b674b71df75>
+ betterbird <https://github.com/NixOS/nixpkgs/pull/528210>
+ beammp-launcher nixpkgs commit 68990df0529b74cde8b63cd1d5f5f5550e630a0c
+ cacert_3108 <https://github.com/NixOS/nixpkgs/blob/9a9ab6b9242c4526f04abeeef99b8de1d7af1fea/pkgs/data/misc/cacert/default.nix>
+ stuntrally ogre mygui nixpkgs commit 56d904a94724499dd1cae942468f8740cdbb112a
+ icu nixpkgs commit 588c72d6229385ef2bab17ec4fc21db014790e4e
+ pkgs/os-specific/linux/kernel/common-flags.nix pkgs/os-specific/linux/zfs/generic.nix nixpkgs commit 154743920299
+ <https://github.com/emmanuelrosa/erosanix/tree/master/pkgs/mkwindowsapp> commit 464f070d952afff764d82041d371cfee3e689d2a mkwindowsapp mkwindowsapp-tools line.nix hooks lib pkgs/wineshell
+ unmodified - prismlauncher-unwrapped prismlauncher materialgram telegram-desktop - should sync with nixpkgs
+ android-translation-layer nixpkgs commit d9f0b9cb3d82342268db374b40bf062ea9a5f044
+ bionic-translation nixpkgs commit d9f0b9cb3d82342268db374b40bf062ea9a5f044
+ art-standalone nixpkgs commit d9f0b9cb3d82342268db374b40bf062ea9a5f044
+ local-ai nixpkgs commit 7377f649a8671844d42dde9ea739961f06ce7edf
+ <https://github.com/maydayv7/dotfiles/raw/refs/heads/stable/packages/wine/notepad++.nix>
+ rclone-ui nixpkgs commit df70bd515ec9175798339adf2ae6a22052d86577
+ pkgs/games/stuntrally/ nixpkgs commit 249e5cbb33fb2ba40ba49cf4ef4bd4c240503516
+ a9ac63c96516b5c14658a14a04fdb1248529d01b nix-output-monitor
+ polkit nixpkgs 88d3861acdd3d2f0e361767018218e51810df8a1
+ darling nixpkgs commit 01b6610eb0c98ee6d840e0d060cb41e334879f65^ 31bdcff5843e30d33eb758334435298a571bd2af^ <https://github.com/NixOS/nixpkgs/commit/31bdcff5843e30d33eb758334435298a571bd2af>
+ widevine-firefox <https://github.com/ToborWinner/teanyth/blob/263decae003ec1b7ed0f7cde30b57c6f2f320c0e/pkgs/firefox-widevine.nix#L4>
+ fdroidcl_git - copied from nixpkgs and updated to <https://github.com/Hoverth/fdroidcl/commit/d870160f16a22836d13f59acdabcd70709c68db6>


+ antigravity-cli <https://github.com/numtide/llm-agents.nix/tree/main/packages/antigravity-cli> commit 04df876de28f0684a0d7110444d7f64da5c14d17
+ antigravity-cli-wrapped: same as above, but with NO_COLOR=1 enforced.
+ antigravity-cli-patched: same as above, but with a binary patch to force simple output.
+ versionCheckHomeHook <https://github.com/numtide/llm-agents.nix/tree/main/packages/versionCheckHomeHook> commit 04df876de28f0684a0d7110444d7f64da5c14d17
+ ryubing - copied from nixpkgs commit [9b50d450945903abb6fb7933c6cfd8f483f0dc2d](https://github.com/NixOS/nixpkgs/tree/9b50d450945903abb6fb7933c6cfd8f483f0dc2d) and modified to copy the desktop/icon files on Darwin to allow `desktopToDarwinBundle` to generate a macOS application bundle.
+ telegram-desktop_682 nixpkgs 8dc49b8b206a683d1f6605e0fd993c0f5d49c98d


## todo - reading

+ <https://github.com/NixOS/nixpkgs/issues/171182#issuecomment-2467081726>

## llm policy

headache. use LLM for boring no brain task

## Python 3.8

While Python 3.8 reached End-Of-Life in October 2024 and is removed from modern NixOS releases, we dynamically fetch the `nixos-23.05` legacy channel inside `beam-studio`'s backend build (`by-name/beam-studio/backend.nix`). This provides a complete Python 3.8 environment and old `opencv-python` wheels necessary to correctly execute the proprietary, decompiled PyInstaller `.pyc` bytecode blobs (`beamify`, `fluxclient`, `fluxsvg`) that `beam-studio` relies on without needing to maintain the outdated Python version globally.
