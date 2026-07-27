# aster-void's nix repository

## Cachix

To use the binary cache, add to your flake:

```nix
{
  nixConfig = {
    extra-substituters = ["https://nix-repository--aster-void.cachix.org"];
    extra-trusted-public-keys = ["nix-repository--aster-void.cachix.org-1:A+IaiSvtaGcenevi21IvvODJoO61MtVbLFApMDXQ1Zs="];
  };
}
```

Or for one-off use:

```bash
nix build --extra-substituters https://nix-repository--aster-void.cachix.org \
          --extra-trusted-public-keys nix-repository--aster-void.cachix.org-1:A+IaiSvtaGcenevi21IvvODJoO61MtVbLFApMDXQ1Zs=
```

> [!WARNING]
> Overriding nixpkgs (e.g., overlays, `nixpkgs.config`) disables binary cache and forces rebuilds from source.

## Maintenance Level

I will maintain packages / modules that are listed in `./nur.nix`.

Other packages are free to use as well, but I won't constantly maintain them.

Packages may be removed without a deprecation period if they become available in nixpkgs or other repositories.

## Docs

- [Installation Guide](./docs/installation.md) - How to install this flake
- [chrome-devtools-mcp](./docs/chrome-devtools-mcp.md)
- [osgrep](./docs/osgrep.md)
