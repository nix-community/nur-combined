# nurpkgs

> Nix User Repository packages

[![GitHub Issues](https://img.shields.io/github/issues/wwmoraes/nurpkgs.svg)](https://github.com/wwmoraes/nurpkgs/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/wwmoraes/nurpkgs.svg)](https://github.com/wwmoraes/nurpkgs/pulls)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)

______________________________________________________________________

## 📝 Table of Contents

- [About](#-about)
- [Getting Started](#-getting-started)
- [Usage](#-usage)
- [Built Using](#-built-using)
- [TODO](./TODO.md)
- [Contributing](./CONTRIBUTING.md)
- [Authors](#-authors)
- [Acknowledgments](#-acknowledgements)

## 🧐 About

Nix packages that aren't popular enough to be in the main nixpkgs repository.
They also deserve some love ❤️

## 🏁 Getting Started

Clone this repository then use `nix-shell --command 'make all'` to build all
packages locally. Check the `Makefile` or use `remake --tasks` for more
commands.

## 🎈 Usage

Import it either directly or through NUR. See instructions below. It takes two
optional parameters:

- `system`, which defaults to `builtins.currentSystem`
- `pkgs`, which defaults to `<nixpkgs>` and inherits `system`

### Direct import

You can use this form in shells, flakes and any other independent nix file.

```nix
{ pkgs, ... }:
let
	nurpkgs = import (builtins.fetchTarball "https://github.com/wwmoraes/nurpkgs/archive/master.tar.gz") { inherit pkgs; };
in { ... }
```

Use `nurpkgs.<package-name>` to reference a package from this repository.

### Through NUR

```nix
let
	pkgs = import <nixpkgs> {
		config.packageOverrides = pkgs: {
			nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
				inherit pkgs;
			};
		};
	};
in { ... }
```

Then use `nur.repos.wwmoraes.<package-name>` to install a package from this
repository. Check <https://github.com/nix-community/NUR> for more details.

### Binary cache

The repository has a companion Cachix binary cache with `aarch64-darwin` and
`x86_64-linux` builds. Use `cachix use wwmoraes` or configure it manually in
your nix settings.

#### NixOS

Add to your `/etc/nixos/configuration.nix`:

```conf
nix.settings.substituters = [
	...
	"https://wwmoraes.cachix.org"
];
nix.settings.trusted-public-keys = [
	...
	"wwmoraes.cachix.org-1:N38Kgu19R66Jr62aX5rS466waVzT5p/Paq1g6uFFVyM="
];
```

#### Other OSes

Add to `/etc/nix/nix.conf`:

```conf
extra-substituters = https://wwmoraes.cachix.org
extra-trusted-public-keys = wwmoraes.cachix.org-1:N38Kgu19R66Jr62aX5rS466waVzT5p/Paq1g6uFFVyM=
```

## 🔧 Built Using

- [Nix](https://nixos.org) - Base language
- [Nixpkgs](https://github.com/NixOS/nixpkgs) - Libraries and much more

## 🧍 Authors

- [@wwmoraes](https://github.com/wwmoraes) - Idea & Initial work

## 🎉 Acknowledgements

- Hat tip to anyone whose code was used
- Inspiration
- References
