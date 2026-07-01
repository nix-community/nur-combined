# augenblick

Fullscreen eye-blink overlay for X11. Every few minutes, two black bars sweep in from the top and bottom of the screen and meet in the middle — then open again. A reminder to blink and rest your eyes.

## Install

```bash
cargo install augenblick
```

Or build from source:

```bash
git clone https://github.com/x71c9/augenblick
cd augenblick
cargo build --release
```

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

