# nur-packages

**Dauliac's personal [NUR](https://github.com/nix-community/NUR) repository**

![Build and notify NUR](https://github.com/Dauliac/nur-packages/workflows/Build%20and%20notify%20NUR/badge.svg)

## Packages

| Attribute | Description |
|---|---|
| `xi` | [xi](https://github.com/Dauliac/xi): yet another nix cli helper |

## Usage

### Via NUR

```nix
{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.nur.repos.Dauliac.xi ];
}
```

### Via this flake directly

```nix
{
  inputs.dauliac-nur.url = "github:Dauliac/nur-packages";
}
```

```console
$ nix run github:Dauliac/nur-packages#xi -- --help
```

### Without flakes

```console
$ nix-build -A xi
$ ./result/bin/xi --version
```

## Relationship to the upstream flake

[xi](https://github.com/Dauliac/xi) builds itself with crane. This repository
deliberately rebuilds the `xi` binary with plain `rustPlatform` so that NUR
evaluation needs nothing beyond nixpkgs: no crane, no second nixpkgs instance,
and no fetch without a hash.

The tradeoff is that `pkgs/xi/default.nix` duplicates the dependency list and
must be bumped in step with upstream releases, and drops the upstream build's
generated shell completions/man page and `nix-auth` PATH wrapper. If you want
the upstream build verbatim, consume that flake directly.

## Adding a package

Add a directory under [`pkgs/`](./pkgs) and wire it into
[`default.nix`](./default.nix). CI runs the same restricted evaluation NUR
itself runs, so an unhashed fetch or an unfree dependency fails here first.
