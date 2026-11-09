# rustdesk-flutter_patched

Patched `rustdesk-flutter` package from Nixpkgs.

## Build issue in upstream Nixpkgs

In nixos-unstable, `rustdesk-flutter` fails during cargo build when compiling `libsodium-sys v0.2.7` because `libsodium` is missing from `buildInputs`:

```
The system library `libsodium` required by crate `libsodium-sys` was not found.
The file `libsodium.pc` needs to be installed and the PKG_CONFIG_PATH environment variable must contain its parent directory.
```

## Fix

Add `libsodium` to `buildInputs`.
