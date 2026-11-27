# augenblick

A blink reminder for the desktop. At regular intervals it closes the screen like an eyelid — two black bars sweep in from the top and bottom and meet in the middle, then open again — as a cue to rest the eyes. A `fill` movement covers the whole screen at once instead of sweeping.

The name is German for "moment", literally "glance of the eye"; in Heidegger it denotes the "moment of vision".

https://github.com/user-attachments/assets/7a6bac03-1e11-4abc-9f07-983a7cfbc963

https://github.com/user-attachments/assets/7e22e591-1fbe-4ca1-9e5e-e41ee1ef960b

https://github.com/user-attachments/assets/3917fc83-7be0-4c79-ab49-4c7f6c793b5c

https://github.com/user-attachments/assets/dcbeb694-89b6-43fd-ba1b-dbab44d70101

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

Add the NUR channel, if not already present:

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

macOS has no X server of its own: augenblick draws the overlay through
[XQuartz](https://www.xquartz.org), the X.Org server for macOS. XQuartz is not
part of macOS since OS X 10.8 and is installed separately (its installer asks
for the administrator password):

```bash
brew install --cask xquartz
brew install x71c9/x71c9/augenblick
```

XQuartz sets `DISPLAY` only for the sessions started after a logout and login.
Until then, XQuartz is started by hand and `DISPLAY` is passed explicitly:

```bash
open -a XQuartz
DISPLAY=:0 augenblick
```

When XQuartz is missing, not running, or `DISPLAY` is not set, augenblick exits
with an error that names the case and the command that fixes it.

The overlay covers the whole screen, menu bar and Dock included. `fade` starts
from black on macOS (see [Config](#config)).

### Pre-built binaries

Archives for each platform are attached to every release on the
[releases page](https://github.com/x71c9/augenblick/releases).

| Platform | File |
|----------|------|
| Linux x86\_64 | `augenblick-x86_64-unknown-linux-gnu.tar.gz` |
| Linux ARM64 | `augenblick-aarch64-unknown-linux-gnu.tar.gz` |
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

The file is read again before every blink, so changes apply from the next
blink on, without a restart.

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

On macOS the fade starts from black instead of from the screen content:
XQuartz runs rootless, so the X root window that augenblick snapshots does not
contain the macOS windows.

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

## Running as a systemd user service

`contrib/augenblick.service` is a systemd user unit that starts augenblick with the graphical session (`graphical-session.target`).
The AUR packages `augenblick` and `augenblick-bin` install it as `/usr/lib/systemd/user/augenblick.service`, with `ExecStart=/usr/bin/augenblick`.
With one of these packages installed, the unit is enabled with:

```bash
systemctl --user enable --now augenblick.service
```

Manual installation, for installs that do not ship the unit:

```bash
install -Dm644 contrib/augenblick.service ~/.config/systemd/user/augenblick.service
systemctl --user daemon-reload
systemctl --user enable --now augenblick.service
```

A `cargo install` build places the binary in `~/.cargo/bin`, so the copied unit requires `ExecStart=%h/.cargo/bin/augenblick`.

The unit starts only when `WAYLAND_DISPLAY` or `DISPLAY` is set in the environment of the systemd user manager.
Most desktop sessions import both variables automatically.
On Sway, Hyprland and other wlroots-based compositors, the compositor configuration has to run:

```bash
systemctl --user import-environment WAYLAND_DISPLAY DISPLAY
```

## Requirements

**Linux:** an X11 server, or a Wayland compositor that supports `wlr-layer-shell` (Sway, Hyprland and other wlroots-based compositors, KDE Plasma). GNOME does not support it.
augenblick speaks the X11 protocol directly and links no X11 library.

**macOS:** [XQuartz](https://www.xquartz.org), installed and running; it is not part of macOS. Setup and `DISPLAY` are described in [macOS — Homebrew](#macos--homebrew), and apply to the pre-built binaries too.

