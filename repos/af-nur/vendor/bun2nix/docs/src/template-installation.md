# From A Template

By default a handful of templates are offered for starting off a new project with bun2nix enabled by default:

- A minimal hello world binary program - the default.
- A basic react website and server setup.
- And the rest in `templates/`

## Notable files

The main files of note are:

- `flake.nix` ⇒ Contains basic project setup for a nix flake for `bun2nix`
- `default.nix` ⇒ Contains build instructions for this bun package
- `bun.nix` ⇒ Generated bun expression from `bun.lock`
- `package.json` ⇒ Standard JavaScript `package.json` with a `postinstall` script pointing to `bun2nix`

## Default - Minimal Setup

To produce the default minimal sample, run:

```bash
nix flake init -t github:nix-community/bun2nix
```

This is a bare-bones project created via `bun init` which produces a simple hello world binary packaged via bun2nix.

## React Website

To start with the React website template run

```bash
nix flake init -t github:nix-community/bun2nix#react
```

This is a simple example of a basic React app built through bun2nix.
