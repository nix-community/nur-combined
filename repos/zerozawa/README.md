# nur-packages

**Zerozawa's [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/lz37/nur/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-zerozawa-blue.svg)](https://zerozawa.cachix.org)

This repository currently exports **22 packages**, **1 library helper**, and placeholder `modules` / `overlays` namespaces.

## Current Exports

### Packages

#### Manga, novels, and media clients

| Package | Description |
|---------|-------------|
| `JMComic-qt` | Qt-based 禁漫天堂 / 18comic desktop client with Vulkan upscaling support |
| `picacg-qt` | Qt-based PicACG desktop client with Vulkan upscaling support |
| `lightnovel-crawler` | Download light novels and generate e-books |

#### Streaming, networking, and developer tools

| Package | Description |
|---------|-------------|
| `StartLive` | Bypass Bilibili LiveHime to obtain streaming addresses |
| `bilibili_live_tui` | Terminal client for Bilibili danmaku send/receive workflows |
| `mihomo-smart` | Mihomo fork with Smart Groups functionality |
| `wechat-web-devtools-linux` | Linux build of the WeChat Mini Program DevTools |
| `agentic-contract` | Policy engine CLI for AI agents |
| `hyprland-mcp-server` | MCP server for Hyprland automation |
| `mcp-cli` | Lightweight CLI for interacting with MCP servers |

#### Desktop customization and utilities

| Package | Description |
|---------|-------------|
| `fortune-mod-zh` | Debian Chinese Team fortune database |
| `fortune-mod-hitokoto` | Hitokoto fortune database |
| `mikusays` | Hatsune Miku themed `cowsay`-style CLI |
| `sddm-eucalyptus-drop` | Eucalyptus Drop SDDM theme |
| `grub-theme-yorha` | YoRHa GRUB theme with selectable resolution |
| `waybar-vd` | Rust Waybar helper for Hyprland virtual desktops |
| `zsh-url-highlighter` | URL syntax highlighting plugin for zsh-syntax-highlighting |

#### SR Vulkan ecosystem

| Package | Description |
|---------|-------------|
| `sr-vulkan` | Vulkan-based super-resolution Python package |
| `sr-vulkan-model-waifu2x` | waifu2x model package for `sr-vulkan` |
| `sr-vulkan-model-realcugan` | realcugan model package for `sr-vulkan` |
| `sr-vulkan-model-realesrgan` | realesrgan model package for `sr-vulkan` |
| `sr-vulkan-model-realsr` | realsr model package for `sr-vulkan` |

### Library helpers

| Export | Description |
|--------|-------------|
| `lib.fetchPixiv` | Fetch Pixiv illustrations by id with configurable mirror and extension fallback |

### Modules and overlays

- `modules` currently exports an empty attribute set placeholder.
- `overlays` currently exports an empty attribute set placeholder.

## Source of Truth

- `default.nix` is the authoritative export surface for packages plus `lib`, `modules`, and `overlays`.
- `lib/default.nix` is the authoritative export surface for library helpers.
- `ci.nix` defines what CI evaluates, builds, and caches.
- `flake.nix` exposes `legacyPackages` and filtered `packages` for flake consumers.

## Usage

### Using through NUR

```nix
{
  imports = [
    (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz")
  ];

  environment.systemPackages = with pkgs.nur.repos.zerozawa; [
    JMComic-qt
    picacg-qt
    hyprland-mcp-server
  ];
}
```

### Using this repository as a flake input

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    zerozawa-nur.url = "github:lz37/nur";
  };

  outputs = { self, nixpkgs, zerozawa-nur }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      packages.${system}.default = pkgs.buildEnv {
        name = "example";
        paths = [
          zerozawa-nur.packages.${system}.mcp-cli
          zerozawa-nur.packages.${system}.hyprland-mcp-server
        ];
      };
    };
}
```

### Using `lib.fetchPixiv`

```nix
let
  repo = import ./. { pkgs = import <nixpkgs> { }; };
in
repo.lib.fetchPixiv {
  id = 81554929;
  p = 0;
  sha256 = "sha256-...";

  # Optional overrides
  mirrors = [ "pixiv.re" "pixiv.cat" "pixiv.nl" ];
  extensions = [ "jpg" "png" ];
}
```

## Build and Check Commands

```bash
# Build a package exported from default.nix
nix-build -A JMComic-qt
nix-build -A hyprland-mcp-server

# Build through flake outputs
nix build .#mcp-cli

# Build what CI caches
nix-build ci.nix -A cacheOutputs

# Inspect flake outputs
nix flake show
```

## CI and Cache Notes

- GitHub Actions builds this repository on push, pull request, schedule, and manual dispatch.
- CI evaluates packages against multiple nixpkgs channels and builds `nix-build ci.nix -A cacheOutputs`.
- Binary cache is published to `https://zerozawa.cachix.org`.

If you want to use the cache locally, prefer declarative Nix configuration instead of commands that mutate the local environment:

```nix
nix.settings.substituters = [
  "https://zerozawa.cachix.org"
  "https://nix-community.cachix.org"
];

nix.settings.trusted-public-keys = [
  "zerozawa.cachix.org-1:9jPl+Xq6S4va32gPNJXTApDafDUwa5zjgFX65QfJ1CQ="
  "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
];
```

## Developer Tooling

This repository also carries local OpenCode metadata in `.opencode/`:

- `.opencode/command/` contains repo-specific command docs for build, check, commit, and update workflows.
- `.opencode/skill/nix-packaging/` contains the local Nix packaging skill used for this repo.
- `.opencode/opencode.jsonc` configures the OpenCode provider and a remote `context7` MCP server.

## License

See each package definition for its own license metadata.
