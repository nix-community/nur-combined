# Bun2Nix Workspace Template

This is a template for a Bun workspace project using bun2nix to create Nix derivations from Bun projects. It demonstrates how to build packages that reference other workspace packages.

## Structure

- `packages/app`: A simple application that depends on the workspace library
- `packages/lib`: A library package that is referenced by the application

## Building

```bash
# Build the app
nix build
```

## Development

```bash
# Enter a development shell with bun available
nix develop
```
