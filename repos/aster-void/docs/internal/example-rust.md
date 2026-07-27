# Rust Packaging Example

## Basic Structure

```nix
# packages/my-rust-app/package.nix
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "my-rust-app";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "owner";
    repo = "my-rust-app";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  cargoHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";

  # Optional: dependencies for building
  nativeBuildInputs = [pkg-config];
  buildInputs = [openssl];

  # Optional: skip tests if they require network
  doCheck = false;

  meta = {
    description = "Short description of the application";
    homepage = "https://github.com/owner/my-rust-app";
    license = lib.licenses.mit;
    maintainers = [];
    mainProgram = "my-rust-app";
    # see ./example-meta.md for more
  };
})
```

## Key Attributes

| Attribute           | Description                                                    |
| ------------------- | -------------------------------------------------------------- |
| `cargoHash`         | Hash of Cargo.lock dependencies. Use `lib.fakeHash` initially. |
| `nativeBuildInputs` | Build-time dependencies (compilers, pkg-config, etc.).         |
| `buildInputs`       | Runtime dependencies (openssl, etc.).                          |
| `doCheck`           | Set to `false` if tests require network access.                |
| `cargoBuildFlags`   | Extra flags for `cargo build`.                                 |

## Common Dependencies

Many Rust packages need system libraries:

```nix
# For packages using OpenSSL
nativeBuildInputs = [pkg-config];
buildInputs = [openssl];

# For packages using SQLite
buildInputs = [sqlite];

# For packages using zlib
buildInputs = [zlib];
```

## Getting Hashes

1. Set `hash` and `cargoHash` to placeholder:

   ```nix
   hash = lib.fakeHash;
   cargoHash = lib.fakeHash;
   ```

2. Run `nix build .#my-rust-app` and copy the correct hashes from error messages.

## Real Example

See [packages/cargo-compete/default.nix](../packages/cargo-compete/default.nix).
