# aster-void's nix repository

## Cachix

To use the binary cache:

```nix
nix.settings = {
  substituters = ["https://nix-repository--aster-void.cachix.org"];
  trusted-public-keys = ["nix-repository--aster-void.cachix.org-1:A+IaiSvtaGcenevi21IvvODJoO61MtVbLFApMDXQ1Zs="];
};
```

Or for one-off use:

```bash
nix build --option extra-substituters https://nix-repository--aster-void.cachix.org \
          --option extra-trusted-public-keys nix-repository--aster-void.cachix.org-1:A+IaiSvtaGcenevi21IvvODJoO61MtVbLFApMDXQ1Zs=
```

## Maintenance Level

I will maintain packages / modules that are listed in `./nur.nix`.

Other packages are free to use as well, but I won't constantly maintain them.

## Docs

- [chrome-devtools-mcp](./docs/chrome-devtools-mcp.md)
- [fcitx5-hazkey](./docs/fcitx5-hazkey.md)
