# nurpkgs


## sources
+ lmms - https://github.com/NixOS/nixpkgs/pull/377643
+ musescore3 - https://aur.archlinux.org/cgit/aur.git/tree/dtl-gcc14-fix.patch?h=musescore3-git https://github.com/NixOS/nixpkgs/blob/31968e86eddf260716458ee9ede65691f6e1987f/pkgs/applications/audio/musescore/default.nix
+ minetest591 - from nixos-24.11 commit 50ab793786d9de88ee30ec4e4c24fb4236fc2674 https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/games/minetest/default.nix
+ minetest580 & irrlichtmt - parent of https://github.com/NixOS/nixpkgs/commit/d61c03fe460f6349e5173e007fb2b678c33bed36 commit 33c8b1a7202d4c22d74f4db73666e9a868069d2c
+ zen-browser https://github.com/NixOS/nixpkgs/pull/363992/files
+ wireguird https://discourse.nixos.org/t/go-version-error-requires-go1-17-or-later/69176/4

##  cache

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

## broken

we need to mark broken for unsupported platforms otherwise the github actions fail