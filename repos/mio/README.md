# nurpkgs

see all packages: <https://nur.nix-community.org/repos/mio/> How to use (NUR guide) <https://nur.nix-community.org/documentation/> You will want to use `nur.repos.mio.*`

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
+ musescore3 - <https://aur.archlinux.org/cgit/aur.git/tree/dtl-gcc14-fix.patch?h=musescore3-git> <https://github.com/NixOS/nixpkgs/blob/31968e86eddf260716458ee9ede65691f6e1987f/pkgs/applications/audio/musescore/default.nix>
+ minetest591 - from nixos-24.11 commit 50ab793786d9de88ee30ec4e4c24fb4236fc2674 <https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/games/minetest/default.nix>
+ minetest580 & irrlichtmt - parent of <https://github.com/NixOS/nixpkgs/commit/d61c03fe460f6349e5173e007fb2b678c33bed36> commit 33c8b1a7202d4c22d74f4db73666e9a868069d2c
+ wireguird <https://discourse.nixos.org/t/go-version-error-requires-go1-17-or-later/69176/4>
+ firefox_nightly, nss_git, shared folder, proton-bin, zfs-impermanence-on-shutdown.nix <https://github.com/chaotic-cx/nyx/commit/aacb796ccd42be1555196c20013b9b674b71df75>
+ betterbird parent of <https://github.com/NixOS/nixpkgs/commit/544076a4a1e72d9267b1ff7601ada5e714cdf101> <https://github.com/NixOS/nixpkgs/raw/7eabf557d4fd5e7195cb3e372304ffdeb04170a9/pkgs/applications/networking/mailreaders/betterbird/default.nix>
+ beammp-launcher nixpkgs commit 68990df0529b74cde8b63cd1d5f5f5550e630a0c
+ cacert_3108 <https://github.com/NixOS/nixpkgs/blob/9a9ab6b9242c4526f04abeeef99b8de1d7af1fea/pkgs/data/misc/cacert/default.nix>
+ stuntrally ogre mygui nixpkgs commit 56d904a94724499dd1cae942468f8740cdbb112a
+ howdy linux-enable-ir-emitter nixpkgs 476d41891299 merged with <https://github.com/NixOS/nixpkgs/pull/216245/files> c003e5440406440bfcf76ce59b890fc2479ae388
+ icu nixpkgs commit 588c72d6229385ef2bab17ec4fc21db014790e4e
+ pkgs/os-specific/linux/kernel/common-flags.nix pkgs/os-specific/linux/zfs/generic.nix nixpkgs commit 154743920299
+ eden <https://github.com/kira-bruneau/nur-packages.git> <https://github.com/kira-bruneau/nur-packages/commit/83867279d2499dd38b944964a829e5c5df93bddc>
+ ego nixpkgs commit 9a1f8b7804ff4bc685b58543c483c52ae967ca63
+ systemd257 <https://github.com/NixOS/nixpkgs/commit/70ca21d3c4982d7f95e48688d02cd9ef6b1347f5>  70ca21d3c4982d7f95e48688d02cd9ef6b1347f5^ <https://github.com/NixOS/nixpkgs/commit/38b523e9e8e607bcd8f638d8a53608bb1658a0e4>
+ davinci-resolve nixpkgs commit 49a636772fd8ea6f25b9c9ff9c5a04434e90b96f^
+ <https://github.com/emmanuelrosa/erosanix/tree/master/pkgs/mkwindowsapp> commit 464f070d952afff764d82041d371cfee3e689d2a mkwindowsapp mkwindowsapp-tools line.nix hooks lib pkgs/wineshell
+ unmodified - prismlauncher-unwrapped prismlauncher materialgram telegram-desktop swt - should sync with nixpkgs
+ android-translation-layer nixpkgs commit d9f0b9cb3d82342268db374b40bf062ea9a5f044
+ bionic-translation nixpkgs commit d9f0b9cb3d82342268db374b40bf062ea9a5f044
+ art-standalone nixpkgs commit d9f0b9cb3d82342268db374b40bf062ea9a5f044
+ local-ai nixpkgs commit 7377f649a8671844d42dde9ea739961f06ce7edf
+ <https://github.com/maydayv7/dotfiles/raw/refs/heads/stable/packages/wine/notepad++.nix>
+ rclone-ui nixpkgs commit df70bd515ec9175798339adf2ae6a22052d86577
+ pkgs/games/stuntrally/ nixpkgs commit 249e5cbb33fb2ba40ba49cf4ef4bd4c240503516
+ 657da505ce2e5888ea07ac228327b7f317763963 nix-output-monitor