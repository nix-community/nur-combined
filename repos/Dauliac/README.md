# nur-packages

**Dauliac's personal [NUR](https://github.com/nix-community/NUR) repository**

![Build and notify NUR](https://github.com/Dauliac/nur-packages/workflows/Build%20and%20notify%20NUR/badge.svg)

## Packages

| Attribute | Description |
|---|---|
| `vsm` | [vault-sessions-manager](https://github.com/Dauliac/vault-sessions-manager): manage multiple HashiCorp Vault contexts and sessions |

## Usage

### Via NUR

```nix
{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.nur.repos.Dauliac.vsm ];
}
```

### Via this flake directly

```nix
{
  inputs.dauliac-nur.url = "github:Dauliac/nur-packages";
}
```

```console
$ nix run github:Dauliac/nur-packages#vsm -- --help
```

### Without flakes

```console
$ nix-build -A vsm
$ ./result/bin/vsm --version
```

## The `vault` runtime dependency

`vsm` shells out to the `vault` CLI. Nixpkgs ships Vault under BUSL-1.1, which
it classifies as **unfree**, so this package does *not* depend on it by
default: forcing an unfree store path during evaluation would break NUR's
indexer, which evaluates every repository with `allowUnfree = false` and
`restrict-eval = true`.

Two ways to get a working `vsm`:

1. **Put `vault` on your PATH yourself** (the default). `vsm` resolves it at
   runtime, so any `vault` you already install works.

2. **Bake the dependency in**, if you accept the BUSL-1.1 terms:

   ```nix
   pkgs.nur.repos.Dauliac.vsm.override { withVaultWrapper = true; }
   ```

   This wraps the binary with `vault` and `xdg-utils` on PATH (the latter is
   needed because `vault login -method=oidc` launches a browser via
   `xdg-open`). It requires `allowUnfree = true` in your nixpkgs config.

## Relationship to the upstream flake

[vault-sessions-manager](https://github.com/Dauliac/vault-sessions-manager)
builds itself with crane against a rust-overlay-pinned 1.90 toolchain. This
repository deliberately rebuilds it with plain `rustPlatform` so that NUR
evaluation needs nothing beyond nixpkgs: no crane, no rust-overlay, no second
nixpkgs instance, and no fetch without a hash.

The tradeoff is that `pkgs/vsm/default.nix` duplicates the dependency list and
must be bumped in step with upstream releases. If you want the upstream build
verbatim, including its home-manager module, consume that flake directly.

## Adding a package

Add a directory under [`pkgs/`](./pkgs) and wire it into
[`default.nix`](./default.nix). CI runs the same restricted evaluation NUR
itself runs, so an unhashed fetch or an unfree dependency fails here first.
