# Bun2Nix sample

Example project created with `bun init` to show usage of `bun2nix`, a fast bun package to nix expression converter written in rust.

This project builds a simple hello world binary that logs `Hello via Bun!` to the console, but also installs some git dependencies of various origins to showcase that it functions.

To try it out use `nix run .`.

## Notable files

The main files of note are:

- `flake.nix` -> Contains basic project setup for a nix flake for `bun2nix`
- `default.nix` -> Contains build instructions for this bun package
- `bun.nix` -> Generated bun expression from `bun.lock`
- `package.json` -> Standard Javascript `package.json` with a `postinstall` script pointing to `bun2nix`
