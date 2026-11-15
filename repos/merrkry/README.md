# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

Packages are available as `nur.repos.merrkry.<package>`, or through this flake:

- `packages.<system>.<package>` for `x86_64-linux` and `aarch64-linux`.
- `overlays.default`, which adds the packages to a nixpkgs instance.

Binaries for `x86_64-linux` are cached at `https://niks3.tsubasa.moe`, which the flake's `nixConfig` declares.

## nix-hash

`nix-hash` checks or updates the fixed-output hashes of a flake's packages, such as `pnpmDeps`. List them in `nix/hash-targets.toml` at the flake root:

```toml
[my-package]
attribute = "my-package.pnpmDeps"
filename = "nix/package.nix"
```

Then run it from the flake root:

```sh
nix run github:merrkry/nur-packages#nix-hash -- update   # recalculate hashes
nix run github:merrkry/nur-packages#nix-hash -- check    # rebuild to verify them
```
