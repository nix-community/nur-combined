# qrx

Selects a region of the screen, reads any QR code found in it, and copies the result to the clipboard. Image files can be decoded as well.

https://github.com/user-attachments/assets/b42862af-7095-444c-9584-d5c2298862a0

## Installation

### NixOS / Nix — NUR

Add the NUR channel, if not already present:

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

Build from source:

```bash
yay -S qrx
```

Or prebuilt binary:

```bash
yay -S qrx-bin
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

Archives for each platform are attached to every release on the
[releases page](https://github.com/x71c9/qrx/releases).

| Platform | File |
|----------|------|
| Linux x86\_64 | `qrx-x86_64-unknown-linux-gnu.tar.gz` |
| Linux ARM64 | `qrx-aarch64-unknown-linux-gnu.tar.gz` |
| macOS Apple Silicon | `qrx-aarch64-apple-darwin.tar.gz` |
| macOS Intel | `qrx-x86_64-apple-darwin.tar.gz` |

## Usage

```bash
qrx                        # crop screen region, copy to clipboard
qrx -p                     # crop screen region, print + copy to clipboard
qrx -pn                    # crop screen region, print only
qrx file.png               # decode image file, copy to clipboard
qrx -p file.png            # decode image file, print + copy to clipboard
qrx -pn file.png           # decode image file, print only
```

### Flags

| Flag | Long | Description |
|------|------|-------------|
| `-p` | `--print` | Print the decoded text to stdout |
| `-n` | `--no-clipboard` | Do not copy to clipboard |
| `-v` | `--version` | Print the version |
| `-h` | `--help` | Print usage, flags and dependencies |

Flags can be combined separately (`-p -n`) or together (`-pn` / `-np`).

### Clipboard

On Linux, the result is copied to both the system clipboard (Ctrl+V) and the primary selection (middle-click).

### Dependencies

| Platform | Required |
|----------|----------|
| X11 | `xclip` |
| Wayland | `slurp`, `grim`, `wl-copy` |
| macOS | — |

## License

MIT
