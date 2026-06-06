# mattrobenolt's nixpkgs

Custom Nix packages that get updated faster than nixpkgs-unstable. Everything here updates automatically via GitHub Actions.

## Packages

### Go

Official Go binaries from go.dev, updated daily. Following the `-bin` naming convention (like `terraform-bin`), these packages use pre-built binaries instead of building from source.

Available packages are generated from `pkgs/go-bin/versions.json`:

- `go-bin` - Latest stable Go version
- `go-bin_next` - Latest Go prerelease, when one is available
- `go-bin_1_26` - Go 1.26.x
- `go-bin_1_25` - Go 1.25.x
- `go-bin_1_24` - Go 1.24.x

When new Go versions are released, they show up here automatically. The updater reads Go's download API, reuses the published archive checksums, converts them to Nix SRI hashes, and commits the changed JSON state.

These packages are named differently from nixpkgs' `go` to avoid invalidating your binary cache. Use them in devShells for fast updates without rebuilding everything that depends on Go.

See [`pkgs/go-bin/README.md`](./pkgs/go-bin/README.md) for implementation details.

### Other packages

- [`hunk`](https://github.com/modem-dev/hunk) - Review-first terminal diff viewer for agent-authored changesets (pre-built binary)
- `inbox` - A fast, beautiful, and distraction-free Gmail client for your terminal (pre-built binary)
- [`prismacat`](https://github.com/mattrobenolt/prismacat) - Themeable truecolor `cat` with Prism syntax highlighting (pre-built binary)
- [`txtar`](https://github.com/mattrobenolt/txtar) - Go-style txtar archive tool (pre-built binary)
- `zed` / `zed-preview` - Linux Zed editor packages for stable and preview releases
- `zigdoc` - Generate documentation from Zig source code
- `ziglint` - An opinionated linter for Zig
- `tracy` - Tracy profiler
- `uvShellHook` - Python virtualenv shell hook helper
- `ast-grep` - Function for wrapping ast-grep with custom Tree-sitter languages

## ast-grep custom languages

`ast-grep` builds a wrapper package that exposes both `ast-grep` and `sg`, generates `sgconfig.yml` in the Nix store, and points custom languages at Tree-sitter parser libraries.

```nix
pkgs.ast-grep {
  languages.zig = {
    grammar = pkgs.tree-sitter-grammars.tree-sitter-zig;
    extensions = [ "zig" ];
    expandoChar = "_";
  };
}
```

Use it in a devshell like any other package:

```nix
pkgs.mkShell {
  packages = [
    (pkgs.ast-grep {
      languages.zig = {
        grammar = pkgs.tree-sitter-grammars.tree-sitter-zig;
        extensions = [ "zig" ];
        expandoChar = "_";
      };
    })
  ];
}
```

Then both commands use the generated config:

```bash
ast-grep -l zig -p 'fn _NAME' src
sg run -l zig -p 'fn _NAME' src
```

For grammars that do not live at `$grammar/parser`, pass `libraryPath` directly. `ruleDirs` and `extraConfig` are also supported:

```nix
pkgs.ast-grep {
  ruleDirs = [ ./rules ];
  extraConfig.utilDirs = [ ./utils ];

  languages.zig = {
    libraryPath = "${pkgs.tree-sitter-grammars.tree-sitter-zig}/parser";
    extensions = [ "zig" ];
    expandoChar = "_";
    languageSymbol = "tree_sitter_zig";
  };
}
```

## Usage

Add this repo as a flake input and apply the overlay:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    mattware = {
      url = "github:mattrobenolt/nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, mattware, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ mattware.overlays.default ];
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.go-bin  # Latest Go
          pkgs.hunk
          pkgs.inbox
          pkgs.prismacat
          pkgs.txtar
        ];
      };
    };
}
```

## Local development

```bash
nix develop

# Update packages
just update go-bin
just update hunk
just update inbox
just update prismacat
just update txtar
just update-all

# Build packages
just build go-bin
just build go-bin_1_24
just build hunk
just build inbox
just build prismacat
just build txtar

# Run packages
nix run .#go-bin -- version
nix run .#hunk -- --help
nix run .#inbox -- --help
nix run .#prismacat -- --help
nix run .#txtar -- -c -f /tmp/readme.txtar README.md
```

## Project Templates

```bash
# Go project
nix flake init -t github:mattrobenolt/nixpkgs#go

# Zig project
nix flake init -t github:mattrobenolt/nixpkgs#zig

# Bun project
nix flake init -t github:mattrobenolt/nixpkgs#bun

# Python project
nix flake init -t github:mattrobenolt/nixpkgs#python
```

## Repository layout

Packages follow a consistent shape:

```text
pkgs/<name>/
  package.nix   # real derivation
  default.nix   # compatibility shim importing package.nix
  hashes.json   # version/hash state, when the package fetches external artifacts
  update.py     # package updater
```

Shared updater helpers live in `scripts/updater/`. Package registration and overlay wiring live in `lib/packages.nix`, keeping `flake.nix` focused on systems, checks, devshells, templates, and outputs.

## How updates work

GitHub Actions runs individual package updaters plus an `update-all` workflow. Updaters write JSON state (`versions.json` / `hashes.json`) instead of regex-editing derivations. The flake reads that state and creates package outputs from it.

Go is the only multi-version package today. Its updater:

1. Reads go.dev's download API
2. Finds the latest stable patch for each tracked minor version
3. Checks Go tags for the latest prerelease
4. Converts upstream SHA256 checksums to Nix SRI hashes
5. Commits changed `versions.json` and `hashes.json`

## Development

```bash
just fmt    # Format Nix and Python files with treefmt
just check  # Run flake checks, including formatting
```

`nix fmt` runs `nixfmt`, `deadnix`, `statix`, and `ruff-format` through treefmt.

## License

MIT
