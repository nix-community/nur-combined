# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

[![Build and populate cache](https://github.com/callumd789/nur-packages/actions/workflows/build.yml/badge.svg)](https://github.com/callumd789/nur-packages/actions/workflows/build.yml)
<!--
TODO: uncomment once the Cachix cache exists (see .github/workflows/build.yml).

[![Cachix Cache](https://img.shields.io/badge/cachix-callumd789-blue.svg)](https://callumd789.cachix.org)
-->

Packages that aren't in nixpkgs. Each one is written in nixpkgs style, so it
can be upstreamed by copying its `package.nix`.

## Packages

| Flake package | Overlay attribute | What it is |
| --- | --- | --- |
| `rustconn` | `pkgs.rustconn` | [RustConn](https://github.com/totoshko88/RustConn), a GTK4 connection manager for SSH, RDP, VNC, SPICE and more, with its `rustconn-cli` |
| `tmux-agent-sidebar` | `pkgs.tmux-agent-sidebar` | The [tmux-agent-sidebar](https://github.com/hiroppy/tmux-agent-sidebar) binary |
| `tmux-agent-sidebar-plugin` | `pkgs.tmuxPlugins.tmux-agent-sidebar` | Its tmux plugin, with `bin/tmux-agent-sidebar` linked to the binary above |

### rustconn

Only the RDP and VNC clients are built in. Every other protocol runs an
external client from `PATH`, SSH and Telnet included (in the built-in
terminal). None of them are wrapped in, so install whichever you need
alongside it:

- `openssh`, for SSH, SFTP and SSH keys
- `inetutils`, for Telnet
- `freerdp` and `tigervnc`, as fallbacks for the built-in RDP and VNC clients
- `virt-viewer`, for SPICE
- `mosh`, `kubectl`, `picocom` (serial), `waypipe`, `mc` (SFTP)
- the password manager and zero trust CLIs you use (`bw`, `op`,
  `keepassxc-cli`, `pass`, `aws`, `gcloud`, `az`, `cloudflared`, ...)

The GUI is built with the `adw-1-8`, `gtk-4-22` and `vte-0-84` features on top
of its defaults, as upstream's Flatpak and distribution packages are.

H.264 in the built-in RDP client needs Cisco's own OpenH264 binary: the loader
rejects any other build, nixpkgs' `openh264` included. RustConn can download it
on request, or point `RUSTCONN_OPENH264` at one. Without it, sessions use
RemoteFX.

### tmux-agent-sidebar

The binary runs these from `PATH` at runtime. They aren't wrapped in, so
install whichever you need alongside it:

- `git`, for repository and branch information
- `gh` (optional), for pull request numbers
- `curl`
- `ps`
- `notify-send`, for desktop notifications

The plugin's `bin/` already holds a binary of the same version as its
`Cargo.toml`, so `tmux-agent-sidebar.tmux` never runs `install-wizard.sh` to
download one.

The plugin directory is also upstream's Claude Code plugin (`.claude-plugin/`,
`hooks/hooks.json`, `hook.sh`), left as is. `hook.sh` looks for the binary in
`~/.tmux/plugins/tmux-agent-sidebar/bin/`, so link
`share/tmux-plugins/tmux-agent-sidebar` there, then add it as a marketplace
with `/plugin marketplace add ~/.tmux/plugins/tmux-agent-sidebar`.

## Usage

As a flake input, with the overlay:

```nix
{
  # No `inputs.nixpkgs.follows`, so the packages are the ones CI caches.
  inputs.nur-packages.url = "github:callumd789/nur-packages";

  # In a NixOS module:
  # nixpkgs.overlays = [ inputs.nur-packages.overlays.default ];
}
```

Or without the overlay, as
`inputs.nur-packages.packages.x86_64-linux.<package>`.

`x86_64-linux` is the only system the flake exposes.

### Avoiding local builds

CI builds the packages against this flake's `flake.lock` and pushes them to
the Cachix cache, so a consumer substitutes them instead of building, as long
as it:

- doesn't make this flake's `nixpkgs` follow its own. With `follows`, every
  bump of the consumer's nixpkgs gives new store paths that no cache has;
- has `https://callumd789.cachix.org` and its public key in
  `nix.settings.extra-substituters` and `extra-trusted-public-keys`. Flake
  `nixConfig` only applies for trusted users;
- updates its lock to a commit whose
  [build](https://github.com/callumd789/nur-packages/actions/workflows/build.yml)
  has finished.

The cost is a second nixpkgs to evaluate, and a second glibc and gcc runtime
in the closure, about 50 MiB.

`overlay.nix` is for non-flake use: it builds against whatever nixpkgs it's
applied to, so nothing is cached for it.

## Layout

- `pkgs/<name>/package.nix`: one directory per package.
- `default.nix`: the package set, calling each package with `callPackage`.
  This is also what NUR imports.
- `overlay.nix`: an overlay that builds the packages against the nixpkgs it's
  applied to. It puts each package where nixpkgs would, so tmux plugins extend
  `pkgs.tmuxPlugins`.
- `flake.nix`: `overlays.default` puts the same attributes in the same places,
  but with the packages built against `flake.lock`.
- `ci.nix`: the buildable and cacheable outputs that CI builds against the
  nixpkgs channel heads.

## Adding a package

1. Write `pkgs/<name>/package.nix` with full `meta` and
   `passthru.updateScript = nix-update-script { };`.
2. Call it from `default.nix`, and add it to both `overlay.nix` and
   `overlays.default` in `flake.nix`.
3. If it has its own `src`, add it to the matrix in
   `.github/workflows/update.yml`.
4. Run `nixfmt` and `statix check`.

## Updates

`.github/workflows/update.yml` runs [nix-update](https://github.com/Mic92/nix-update)
every Monday and opens a pull request for each package with a new release,
pushing the new builds to Cachix before it does. Dependabot updates
`flake.lock` weekly. To update a package by hand:

```sh
nix run nixpkgs#nix-update -- --flake tmux-agent-sidebar
```
