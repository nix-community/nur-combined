# nur-packages

**Chen's personal [NUR](https://github.com/nix-community/NUR) repository**

<!-- Remove this if you don't use github actions -->
![Build and populate cache](https://github.com/cu1ch3n/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-chen-blue.svg)](https://chen.cachix.org)

## Papilot

`nur.repos.chen.papilot` includes the CLI, browser interface, TeX Live and the
Electron desktop application on Linux. `nur.repos.chen.papilot-cli` omits the
Electron launcher and also supports Apple Silicon macOS.

With the NUR overlay configured in NixOS:

```nix
environment.systemPackages = [ pkgs.nur.repos.chen.papilot ];
```

The repository's flake can also be installed directly:

```sh
nix profile install github:cu1ch3n/nur-packages#papilot
# CLI only (also available on Apple Silicon macOS):
nix profile install github:cu1ch3n/nur-packages#papilot-cli
```

Run `papilot` for the browser interface, `papilot-desktop` for the Linux desktop,
or select Papilot in the application menu. `papilot doctor` checks the setup.
Use Nix to update the package; npm updates and desktop hot updates are disabled.
Existing agents are discovered through PATH, Nix profiles and their standard
installation folders. No agent is installed automatically. An explicit
`PAPILOT_CODEX_BIN`, `PAPILOT_CLAUDE_BIN`, or other agent binary setting takes
priority. Agent sign-in and subscriptions remain separate from this package.

The source revision and content hash are pinned in `pkgs/papilot/source.nix`.
The Papilot workflow boots the actual package in an x86_64 NixOS VM and checks
the desktop, SQLite, PDF compilation, SyncTeX and isolated user data. ARM Linux
is declared as a supported build target but has not had native runtime testing.
