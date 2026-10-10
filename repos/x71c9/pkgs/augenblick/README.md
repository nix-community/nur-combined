# augenblick

Reminds you to blink. At regular intervals, it closes your screen like an eyelid — two black bars sweep in from the top and bottom and meet in the middle, then open again — so you rest your eyes. A `fill` movement covers the whole screen at once instead of sweeping.

https://github.com/user-attachments/assets/5b0d6ae7-d471-4bfc-916b-0549f1a7d788

## Usage

```bash
augenblick
```

Blinks once at startup, then every 4 minutes.

```
Options:
  -c <path>               config file (default: ~/.config/augenblick/augenblick.toml)
  -n <n>                  number of blinks, then exit (default: run forever)
  --sleep_secs <n>        seconds between blinks (default: 240)
  --animation_frames <n>  frames per eyelid sweep (default: 20)
  --color <hex>           eyelid color, e.g. #ff0000 (default: #000000);
                          repeatable, each blink picks one at random
  --movement <name>       blink: lids sweep in from top and bottom (default);
                          fill: the whole screen is covered at once, no sweep
  --fade <ms>             fade in and out over this many milliseconds (default: 0, off)
  --hold <ms>             time the screen stays fully covered
                          (default: 150 for blink, the length of a blink for fill)
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
movement = "blink"
fade = 0
hold = 150
```

CLI flags override config file values.

`color` also accepts an array. Each blink then picks one of the colors at
random:

```toml
color = ["#cc241d", "#98971a", "#d79921", "#458588", "#b16286", "#689d6a"]
```

On the command line, `--color` can be repeated for the same effect:

```bash
augenblick --color '#cc241d' --color '#458588'
```

`movement` selects how the screen is covered:

- `blink` (default): two lids sweep in from the top and bottom edges, meet in
  the middle, pause, then sweep back out.
- `fill`: the whole screen is covered with the color at once, held, then
  uncovered. No sweep.

```toml
movement = "fill"
```

```bash
augenblick --movement fill
```

`hold` sets how long the screen stays fully covered, in milliseconds. With
`blink` it is the pause between the closing and the opening sweep, 150 ms by
default. With `fill` it is the whole covered time; when unset it lasts as long
as a full blink would with the same `animation_frames`, about 800 ms with the
defaults.

```toml
movement = "fill"
hold = 2000
```

```bash
augenblick --movement fill --hold 2000
```

`fade` fades the overlay in and out over the given number of milliseconds.
With `fill`, the fade-in runs before the hold and the fade-out after it, so
the screen stays covered for `hold` plus twice `fade`. With `blink`, the
opacity ramps up during the first `fade` ms of the sweep and down during the
last `fade` ms. Zero (the default) disables fading.

```toml
fade = 300
```

```bash
augenblick --movement fill --fade 300
```

No compositor is needed. On X11 the screen is snapshotted before the overlay
appears and the color is blended over that snapshot with XRender, so the
content under the overlay is frozen for the duration of the blink. On Wayland
the overlay is drawn with real alpha.

augenblick does not read colors from the desktop theme. To match a rice,
the theming tool (pywal templates, Stylix, home-manager, …) generates
`augenblick.toml` with the palette.

## Requirements

**Linux:** X11 with `libxcb` installed.

**macOS:** [XQuartz](https://www.xquartz.org) must be installed and running. Launch it before running augenblick:

```bash
open -a XQuartz
DISPLAY=:0 augenblick
```

