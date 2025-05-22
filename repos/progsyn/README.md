# Nix Derivations for Program Synthesis Tools

![Build and populate cache](https://github.com/mistzzt/program-synthesis-nur/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-mistzzt-blue.svg)](https://mistzzt.cachix.org)

This repository hosts Nix derivations for program synthesis-related tools.
Its aim is to consolidate the efforts of individuals who set up and run these tools by leveraging the reproducibility power of Nix.
Contributions are welcomed!

## Getting Started with Our Nix Flake Template

We provide [`template.nix`](./template.nix), a minimal Nix flake template that defines a development shell environment with `z3`, `cvc5`, and `Sketch`.

### Quick Setup Guide

1. **Initialize Your Project**: Copy the `template.nix` file into your project's root directory and rename it to `flake.nix`
2. **Customize Your Environment/Package**: Change your devShell environment or define your packages
3. **Launch/Build**: Use `nix develop` to enter the default devShell, or use `nix build` to build your package

## More Program Synthesis Tools with Nix Derivations

- EUSolver: https://github.com/mistzzt/EUSolver
- Opera: https://github.com/utopia-group/Opera

If you're working with or developing a tool that you believe should be listed here, please reach out.
