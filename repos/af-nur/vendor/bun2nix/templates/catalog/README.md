# Bun2Nix Catalog Template

This is a template for a Bun workspace project that uses the
[`catalog:` protocol](https://bun.com/docs/pm/catalogs) to centralise
dependency versions, built with bun2nix.

It exercises both the default catalog and a named catalog (`catalog:tooling`).

## Structure

- `packages/app`: A simple application that depends on the workspace library
  via `catalog:`.
- `packages/lib`: A library package whose npm dependency is pinned via the
  default catalog.

## Building

```bash
nix build
```

## Development

```bash
nix develop
```
