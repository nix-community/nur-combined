# nurpkgs

see all packages: <https://nur.nix-community.org/repos/mio/>

+ linux: x86_64-v3, aarch64
+ darwin: aarch64

## cache

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

a binary cache may be available on Garnix. See <https://garnix.io/docs/caching/>

## broken

we need to mark broken for unsupported platforms otherwise the github actions fail

## sources

+ lmms - <https://github.com/NixOS/nixpkgs/pull/377643>
+ musescore3 - <https://aur.archlinux.org/cgit/aur.git/tree/dtl-gcc14-fix.patch?h=musescore3-git> <https://github.com/NixOS/nixpkgs/blob/31968e86eddf260716458ee9ede65691f6e1987f/pkgs/applications/audio/musescore/default.nix>
+ minetest591 - from nixos-24.11 commit 50ab793786d9de88ee30ec4e4c24fb4236fc2674 <https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/games/minetest/default.nix>
+ minetest580 & irrlichtmt - parent of <https://github.com/NixOS/nixpkgs/commit/d61c03fe460f6349e5173e007fb2b678c33bed36> commit 33c8b1a7202d4c22d74f4db73666e9a868069d2c
+ wireguird <https://discourse.nixos.org/t/go-version-error-requires-go1-17-or-later/69176/4>
+ jellyfin-media-player copy from nixpkgs commit 68990df0529b74cde8b63cd1d5f5f5550e630a0c
+ firefox_nightly, nss_git, shared folder <https://github.com/chaotic-cx/nyx>
+ betterbird parent of <https://github.com/NixOS/nixpkgs/commit/544076a4a1e72d9267b1ff7601ada5e714cdf101> <https://github.com/NixOS/nixpkgs/raw/7eabf557d4fd5e7195cb3e372304ffdeb04170a9/pkgs/applications/networking/mailreaders/betterbird/default.nix>
+ beammp-launcher nixpkgs commit 68990df0529b74cde8b63cd1d5f5f5550e630a0c
+ cacert_3108 <https://github.com/NixOS/nixpkgs/blob/9a9ab6b9242c4526f04abeeef99b8de1d7af1fea/pkgs/data/misc/cacert/default.nix>
+ swt nixpkgs commit 0a381edbc370fe8f15106b957fc52ef8f2589e74
+ shell-gpt nixpkgs commit 036c3539550f49b625e98fdda29e16cca62040a1
+ speed-dreams stuntrally ogre mygui nixpkgs commit 56d904a94724499dd1cae942468f8740cdbb112a
