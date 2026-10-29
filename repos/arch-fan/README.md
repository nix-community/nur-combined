# nur-packages

Personal [NUR](https://github.com/nix-community/NUR) package set (flake, `x86_64-linux`).

## Packages

| Package | Description |
| --- | --- |
| `chat-on-steroids` | [Chat On Steroids](https://github.com/totec448-spec/chat-on-steroids): local coding bridge for ChatGPT (MCP, Chrome integration, multi-agent workflows), wrapped from the upstream AppImage |
| `crunchyroll` | Desktop entry launching Crunchyroll as a Chromium `--app` window (WideVine enabled) |
| `limusic` | [Limusic](https://github.com/SimoHypers/limusic): native desktop YouTube Music client (Tauri, ad-free playback via libmpv), wrapped from the upstream AppImage |
| `local-shell-mcp` | [local-shell-mcp](https://github.com/fwerkor/local-shell-mcp): MCP server giving LLMs a shell, from the upstream binary release |
| `rpcs3-bin` | [RPCS3](https://rpcs3.net/) PlayStation 3 emulator, wrapped from the upstream nightly AppImage |

## Use

```console
nix run github:arch-fan/nur-packages#limusic
```

Through NUR (`nur.repos.arch-fan.limusic`) or as a flake input (NixOS example):

```nix
environment.systemPackages = [
  inputs.nur-packages.packages.x86_64-linux.limusic
  inputs.nur-packages.packages.x86_64-linux.crunchyroll
];
```

## Layout

`pkgs/<name>/package.nix` is picked up automatically as the package `<name>`
(`lib.packagesFromDirectoryRecursive`, the nixpkgs `by-name` convention). Write
packages in the `finalAttrs` style and keep fetch URLs interpolating the version,
so a bump is a two-line diff.

`nix fmt` formats everything (nixfmt); `nix flake check` builds every package and
runs the checks below.

### AppImage library check

NUR builds these packages against its users' nixpkgs, not this flake's lock, and
nixpkgs occasionally drops libraries from `appimageTools`' default FHS env. The
wrapper still builds, but the app dies at launch with
`error while loading shared libraries: libfoo.so: cannot open shared object file`.

`checks/appimage-libs.nix` catches that at build time. For every package that has
`contents` and `fhsenv` (i.e. built with `appimageTools.wrapType2` or
`wrapAppImage`), it fails if any bundled ELF needs a library that neither the
AppImage nor the FHS env provides. Fix a failure by adding the providing package
to `extraPkgs`. The check is wired up automatically; new AppImage packages need
nothing extra.

## Updates

A nightly workflow (`.github/workflows/update.yaml`, also manually dispatchable):

1. `nix flake update`: tracks nixos-unstable, so nixpkgs breakage surfaces here
   before NUR users hit it;
2. `nix run .#update`: runs `nix-update --flake --build -u` on every package in
   `pkgs/`;
3. `nix flake check`: builds everything and runs the library check;

then opens a single auto-merged PR (`updates/packages`). Any failure stops the run
before the PR, and GitHub emails the failure.

Conventions for `scripts/update.sh`:

- **Normal packages** need nothing special: nix-update compares against upstream
  releases and rewrites `version` + `hash`.
- **Per-package flags** (e.g. `--version-regex`, `--version=branch`) or custom
  logic go in the derivation, the nixpkgs-idiomatic way. `-u` runs it when present:

  ```nix
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  ```

- **Opting out**: a package nix-update cannot evaluate (no `version`, e.g. the
  `crunchyroll` desktop entry) gets a `pkgs/<name>/no-auto-update` file
  explaining why; the script skips it.
