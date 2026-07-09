# Prince NixOS Flake Configuration

[![NixOS](https://img.shields.io/badge/NixOS-5277C3?logo=nixos&logoColor=white)](https://nixos.org)
[![Prince](https://img.shields.io/badge/Prince-16.2-orange)](https://www.princexml.com/)

A NixOS package for **Prince** — a tool that converts HTML documents to PDF using
CSS. This package wraps the official generic Linux binary with automatic library
path configuration via `autoPatchelfHook`.

**Platforms:** `x86_64-linux`, `aarch64-linux`

---

## Installation

Add this package to your NixOS configuration flake inputs:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    configs.url = "github:ahmet-cetinkaya/dotfiles";
  };

  outputs = { self, nixpkgs, configs, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          environment.systemPackages = [
            configs.packages.x86_64-linux.prince-bin
          ];
        }
      ];
    };
  };
}
```

`nixpkgs.config.allowUnfree = true;` is required — Prince is distributed under a
proprietary license.

---

## Usage

Convert an HTML document to PDF:

```bash
prince input.html -o output.pdf
```

See the [Prince documentation](https://www.princexml.com/doc/) for CSS support
and command-line options.

---

## Updating

An update script is provided to automatically fetch the latest release:

```bash
./update.sh
```

The script:
1. Resolves the latest Prince version from [princexml.com](https://www.princexml.com/)
2. Downloads tarballs for both `x86_64` and `aarch64` architectures
3. Computes SHA256 hashes for each
4. Updates `default.nix` with the new version and hashes

---

## Runtime Dependencies

The package bundles and patches the following runtime libraries:

| Library      | Purpose                          |
|--------------|----------------------------------|
| `fontconfig` | Font rendering                   |
| `libidn`     | Internationalized domain names   |
| `libxml2`    | XML parsing                      |
| `zlib`       | Compression                      |
| `cacert`     | CA certificate bundle (TLS)      |

---

## Package Structure

```text
prince-bin/
├── default.nix       # Nix derivation (version, sources, build inputs, install phase)
├── update.sh         # Script to fetch latest release and update hashes
└── README.md
```

---

## License

Prince is proprietary software; it is free for non-commercial use and adds a
watermark to output unless licensed. See the
[Prince licensing page](https://www.princexml.com/purchase/) for details.
