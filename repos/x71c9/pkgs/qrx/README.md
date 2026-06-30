# qrx

CLI tool to capture a screen region, decode any QR code found, and copy the result to clipboard.

## Installation

### NixOS / Nix — NUR

Add the NUR channel if you haven't already:

```bash
nix-channel --add https://github.com/nix-community/NUR/archive/master.tar.gz nur
nix-channel --update
```

Then install:

```nix
# configuration.nix
environment.systemPackages = [
  nur.repos.x71c9.qrx
];
```

Or ad-hoc:

```bash
nix-env -f '<nixpkgs>' -iA nur.repos.x71c9.qrx
```

### Linux — AUR (Arch Linux)

```bash
yay -S qrx-bin
# or
paru -S qrx-bin
```

### crates.io — Cargo

```bash
cargo install qrx
```

### macOS — Homebrew

```bash
brew install x71c9/x71c9/qrx
```

### Pre-built binaries

Download the latest release for your platform from the
[releases page](https://github.com/x71c9/qrx/releases).

| Platform | File |
|----------|------|
| Linux x86\_64 | `qrx-x86_64-unknown-linux-musl.tar.gz` |
| macOS Apple Silicon | `qrx-aarch64-apple-darwin.tar.gz` |
| macOS Intel | `qrx-x86_64-apple-darwin.tar.gz` |

## Usage

```bash
qrx --help
```

## License

MIT

