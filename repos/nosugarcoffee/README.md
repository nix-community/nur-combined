# nur-packages

Nix packages that nixpkgs lacks, lags on, or only ships for Linux — mostly macOS apps
repacked from their official releases. Every package follows its upstream automatically:
a workflow checks for new releases 4× a day, builds the bump, and merges it.

Modeled on [numtide/llm-agents.nix](https://github.com/numtide/llm-agents.nix).

## Packages

| Package | Platforms | Description |
|---|---|---|
| [`_1password-cli`](https://developer.1password.com/docs/cli/) | aarch64-darwin, x86_64-linux, aarch64-linux | 1Password CLI (`op`), signed official release; newer than nixpkgs' |
| [`_1password-gui`](https://1password.com/) | aarch64-darwin | 1Password desktop app, notarized official release from the stable channel; newer than nixpkgs' |
| [`agent-access`](https://github.com/bitwarden/agent-access) | aarch64-darwin, x86_64-linux | Bitwarden's CLI and SDK for giving agents credentials without exposing the whole vault (`aac`) |
| [`albert`](https://albertlauncher.github.io) | aarch64-darwin | Keyboard launcher, built from source for macOS (nixpkgs' is Linux-only) |
| [`cida`](https://github.com/Xuanwo/cida) | aarch64-darwin | Translate and polish text anywhere on macOS with an LLM of your choice |
| [`clash-verge-rev`](https://www.clashverge.dev/) | aarch64-darwin | Clash Meta GUI (nixpkgs' is Linux-only) |
| [`cua-driver`](https://github.com/trycua/cua) | aarch64-darwin, x86_64-linux, aarch64-linux | Computer-use MCP server and CLI. Link `cua-driver.skills` into `~/.claude/skills` |
| [`digup`](https://github.com/ARahim3/DigUp) | aarch64-darwin | Search files by their content with on-device embeddings |
| [`ego-lite`](https://lite.ego.app/) | aarch64-darwin | Chromium-based browser that shares your logged-in state with AI agents, plus the `ego-browser` CLI |
| [`jetbrains-air`](https://air.dev/) | aarch64-darwin | JetBrains Air, an agentic development environment |
| [`obs-studio`](https://obsproject.com/) | aarch64-darwin | Streaming and screen recording (nixpkgs' is Linux-only) |
| [`pulsar`](https://pulsar-edit.dev/) | aarch64-darwin | Community-led hyperhackable text editor, the Atom successor (nixpkgs' is Linux-only) |
| [`qingjian`](https://qingjian.app) | aarch64-darwin | Pinyin input method that shows a word in the language you are learning beside each candidate (installs under `Library/Input Methods`) |
| [`scroll-reverser`](https://pilotmoon.com/scrollreverser/) | aarch64-darwin | nixpkgs' Scroll Reverser with the AppleDouble files that make Gatekeeper reject it removed |

Several are unfree (`_1password-cli`, `_1password-gui`, `ego-lite`, `jetbrains-air`); allow unfree packages to use them.

## Usage

As a flake input:

```nix
{
  inputs.nur-packages.url = "github:NoSugarCoffee/nur-packages";

  # then, e.g. in home-manager:
  home.packages = [ inputs.nur-packages.packages.aarch64-darwin.obs-studio ];
}
```

`packages.<system>` holds only what builds on that system, built against this flake's pinned
nixpkgs-unstable (which is what the cache below serves). To build against your own nixpkgs
instead, use the overlay; packages land under `pkgs.nosugarcoffee`:

```nix
nixpkgs.overlays = [ inputs.nur-packages.overlays.default ];
# pkgs.nosugarcoffee.obs-studio
```

Without flakes, `import (fetchTarball "https://github.com/NoSugarCoffee/nur-packages/archive/main.tar.gz") { inherit pkgs; }`
returns the same set.

### Binary cache

CI pushes every build to the `nosugarcoffee` [Cachix](https://app.cachix.org/cache/nosugarcoffee) cache:

```sh
cachix use nosugarcoffee
```

or in `nix.conf` (this flake's `nixConfig` also offers it when you build from it directly):

```
extra-substituters = https://nosugarcoffee.cachix.org
extra-trusted-public-keys = nosugarcoffee.cachix.org-1:gQkOArBt+myqJZvfmk4L6LqbuScp2LCn2fG1bWRoJhE=
```

Packages are cached as built against this flake's pinned nixpkgs, so the cache serves
`packages.<system>`; the overlay builds against your nixpkgs and usually misses it.

## How updates work

Each package is `pkgs/<name>/package.nix`, and if it follows an upstream release, a
`pkgs/<name>/pin.json` with the version, URL template and per-system hashes. The
[Update workflow](.github/workflows/update.yml) runs `scripts/release_pins.py` 4× a day: it asks
each upstream (GitHub releases, the JetBrains products API, a vendor's RSS release feed, or a
re-fetch for vendors with unversioned URLs) for its latest release, prefetches the new hashes, builds the bumped packages
on macOS, and merges the PR when they build. A failed build leaves the PR open.

## Adding a package

1. Create `pkgs/<name>/package.nix` — it's picked up automatically. Take the nixpkgs package of
   the same name as an argument to adapt it instead (see `pkgs/albert`).
2. For a release download, add `pkgs/<name>/pin.json` and load it with `lib/release-pin.nix`
   (see `pkgs/cida`); the updater then keeps it current.
3. Add a row to the table above (a test checks it).
