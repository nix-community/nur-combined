# mnamer-rs

Rust v3 development build of [mnamer](https://github.com/jkwill87/mnamer),
packaged from [crates.io](https://crates.io/crates/mnamer). Requires Rust 1.97+
from the caller's nixpkgs. Commands and `mnamer.toml` configuration differ from
Python v2. Both install `mnamer`; do not install them in the same profile.

## Usage

```sh
nix-build -A mnamer-rs
./result/bin/mnamer version
./result/bin/mnamer help move
```

Select `(import /path/to/nur-packages { inherit pkgs; }).mnamer-rs` to install.
Preview with `mnamer move <directory> --recursive --test --batch`; metadata
lookups may access the network and write cache entries. Keep API keys in runtime
environment variables or private configuration, outside the Nix store.

## Maintenance

```sh
nix-shell --run 'just update mnamer-rs'
nix-shell --run 'just check mnamer-rs'
```

Updates select non-yanked `3.0.0-devN` crates and pin the version, source hash and
local `Cargo.lock` (missing from the dev5 crate). Dependencies resolve only during
updates, not builds. Review the manifest, Rust requirement and CLI/configuration
changes; revisit version selection when stable v3 is released.

Build and installed version/help tests pass on `x86_64-linux`. `aarch64-linux`
and `aarch64-darwin` pass evaluation only; native builds and runtime tests remain
unverified. Upstream unit suites, online metadata requests and media operations
are not tested.
