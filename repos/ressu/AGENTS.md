# Project Overview

This is a [Nix User Repository (NUR)](https://github.com/nix-community/NUR) for personal Nix packages. It uses [Nix Flakes](https://nixos.wiki/wiki/Flakes) to manage dependencies and provide packages. The repository is structured to allow for easy addition of new packages, libraries, NixOS modules, and overlays.

## Main Technologies

*   **Nix:** The project is built entirely with the Nix package manager.
*   **Nix Flakes:** The project uses Nix Flakes to define dependencies and outputs.
*   **GitHub Actions:** The project uses GitHub Actions for continuous integration.

## Architecture

The repository is structured as follows:

*   `flake.nix`: The main entry point for the Nix Flake. It defines the inputs and outputs of the project.
*   `default.nix`: The main file that describes the repository contents. It returns a set of Nix derivations, libraries, modules, and overlays.
*   `pkgs/`: This directory contains the individual Nix packages. Each package is a Nix derivation defined in a `default.nix` file.
*   `lib/`: This directory contains utility functions.
*   `modules/`: This directory contains NixOS modules.
*   `overlays/`: This directory contains nixpkgs overlays.
*   `.github/workflows/build.yml`: This file defines the GitHub Actions workflow for building and caching the packages.
*   `ci.nix`: This file defines which packages to build and cache.

# Building and Running

## Building a single package

To build a single package, you can use the `nix-build` command. For example, to build the `example-package`, you would run the following command:

```bash
nix-build -A example-package
```

## Building all packages

To build all packages, you can use the `nix-build` command with the `ci.nix` file.

```bash
nix-build ci.nix -A buildOutputs
```

# Development Conventions

## Adding a new package

To add a new package, you need to:

1.  Create a new directory in the `pkgs/` directory.
2.  Create a `default.nix` file in the new directory that defines the package as a Nix derivation.
3.  Add the new package to the `default.nix` file in the root of the repository.

## Marking packages as broken

If a package is broken, you should mark it as `broken = true;` in the `meta` attribute of the package derivation. This will prevent the CI from trying to build it.

## Continuous Integration

The project uses GitHub Actions for continuous integration. The CI workflow is defined in the `.github/workflows/build.yml` file. The CI builds all the packages and caches the results in [Cachix](https://www.cachix.org/).
