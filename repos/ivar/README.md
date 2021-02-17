# Up-to-date versions of yuzu and Ryujinx for nix

This NUR repo contains up to date versions of Ryujinx, yuzu-mainline and yuzu-ea (early-access).

These packages take quite a while to compile, so I've set up a binary cache using [cachix](https://app.cachix.org/).

```
nix run nixpkgs.cachix -c cachix use ivar
```
