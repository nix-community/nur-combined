---
name: nix
description: Run packages temporarily, create isolated shell environments, and evaluate Nix expressions. Use when executing tools without installing, debugging derivations, or searching nixpkgs.
---

# Nix Skill

Nix is a powerful package manager and functional programming language. This skill covers common operations like running apps on-the-fly and managing environments.

## Running Applications

You can run any application from `nixpkgs` without installing it permanently.

```bash
# Run a package once
nix run nixpkgs#hello

# Run a package with specific arguments
nix run nixpkgs#cowsay -- "Hello from Nix!"

# Run a command within a shell environment (non-interactive)
nix shell nixpkgs#git nixpkgs#vim --command git --version

# Run long-running applications (e.g., servers): `tmux new -d 'nix run nixpkgs#some-server'`
```

## Formatting

Format Nix files in your project:

```bash
# Format current flake
nix fmt

# Check formatting
nix fmt -- --check
```

## Evaluating Expressions (Debugging)

Since the environment is headless and non-interactive, use `nix eval` instead of the REPL for debugging.

```bash
# Evaluate a simple expression
nix eval --expr '1 + 2'

# Inspect an attribute from nixpkgs
nix eval nixpkgs#hello.name

# Evaluate a local nix file
nix eval --file ./default.nix

# List keys in a set (useful for exploration)
nix eval --expr 'builtins.attrNames (import <nixpkgs> {})'
```

## Searching for Packages

```bash
# Search for a package by name or description
nix search nixpkgs python3
```

## Common Nix Language Patterns

### Variables and Functions

```nix
# Let binding
let
  name = "Nix";
in
  "Hello ${name}"

# Function definition
let
  multiply = x: y: x * y;
in
  multiply 2 3
```

### Attribute Sets

```nix
{
  a = 1;
  b = "foo";
}
```

## Shebang Scripts

Use Nix as a script interpreter:

```bash
#!/usr/bin/env nix
#! nix shell nixpkgs#bash nixpkgs#curl --command bash

curl -s https://example.com
```

Or with flakes:

```bash
#!/usr/bin/env nix
#! nix shell nixpkgs#python3 --command python3

print("Hello from Nix!")
```

## Troubleshooting

- **Broken Builds**: Use `nix log` to see the build output of a derivation.
- **Dependency Issues**: Use `nix-store -q --references $(which program)` to see what a program depends on.
- **Cache issues**: Add `--no-substitute` to force a local build if you suspect a bad binary cache.
- **Why depends**: Use `nix why-depends nixpkgs#hello nixpkgs#glibc` to see dependency chain.

## Related Skills

- **nix-flakes**: Use Nix Flakes for reproducible builds and dependency management in Nix projects.
- **nh**: Manage NixOS and Home Manager operations with improved output using nh.

## Related Tools

- **search-nix-packages**: Search for packages available in the NixOS package repository.
- **search-nix-options**: Find configuration options available in NixOS.
- **search-home-manager-options**: Find configuration options for Home Manager.
