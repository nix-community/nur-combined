# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/ggemre/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

## Updating a package:

For `pkgs/stacklet/default.nix`:
1. Update version number
2. Replace `sha256` property with output of `nix-prefetch-url --unpack https://github.com/ggemre/stacklet/archive/<VERSION>.tar.gz`
3. Run `nix-shell --arg pkgs 'import <nixpkgs> {}' -A stacklet`, this will output something akin to:
```sh
error: hash mismatch in fixed-output derivation '/nix/store/<HASH>-stacklet-<VERSION>-vendor.tar.gz.drv':
         specified: <OLd_HASH>
            got:    <NEW_HASH>
```
4. Replace `cargoSha256` property with `<NEW_HASH>`
5. Rerun `nix-shell --arg pkgs 'import <nixpkgs> {}' -A stacklet` to confirm stacklet builds properly, then commit and push
```sh
git commit -am "Update stacklet <VERSION>"
git push
```
