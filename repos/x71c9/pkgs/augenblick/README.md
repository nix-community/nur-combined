# augenblick

Reminds you to blink. At regular intervals, it closes your screen like an eyelid — two black bars sweep in from the top and bottom and meet in the middle, then open again — so you rest your eyes.

## Usage

```bash
augenblick
```

Blinks once at startup, then every 4 minutes.

```
Options:
  -c <path>               config file (default: ~/.config/augenblick/augenblick.toml)
  --sleep_secs <n>        seconds between blinks (default: 240)
  --animation_frames <n>  frames per eyelid sweep (default: 20)
  --color <hex>           eyelid color, e.g. #ff0000 (default: #000000)
  -V, --version           print version
  -h, --help              show this help
```

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
  nur.repos.x71c9.augenblick
];
```

Or ad-hoc:

```bash
nix-env -f '<nixpkgs>' -iA nur.repos.x71c9.augenblick
```

### Linux — AUR (Arch Linux)

Build from source:

```bash
yay -S augenblick
```

Or prebuilt binary:

```bash
yay -S augenblick-bin
```

### crates.io — Cargo

```bash
cargo install augenblick
```

### macOS — Homebrew

```bash
brew install x71c9/x71c9/augenblick
```

### Pre-built binaries

Download the latest release for your platform from the
[releases page](https://github.com/x71c9/augenblick/releases).

| Platform | File |
|----------|------|
| Linux x86\_64 | `augenblick-x86_64-unknown-linux-musl.tar.gz` |
| macOS Apple Silicon | `augenblick-aarch64-apple-darwin.tar.gz` |
| macOS Intel | `augenblick-x86_64-apple-darwin.tar.gz` |


## Config

`~/.config/augenblick/augenblick.toml` (all fields optional):

```toml
sleep_secs = 240
animation_frames = 20
color = "#000000"
```

CLI flags override config file values.

## Requirements

**Linux:** X11 with `libxcb` installed.

**macOS:** [XQuartz](https://www.xquartz.org) must be installed and running. Launch it before running augenblick:

```bash
open -a XQuartz
DISPLAY=:0 augenblick
```

