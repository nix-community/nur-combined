# so1ve/nur-packages

Ray's personal [NUR](https://github.com/nix-community/NUR) repository

[![CI](https://github.com/so1ve/nur-packages/actions/workflows/ci.yml/badge.svg)](https://github.com/so1ve/nur-packages/actions/workflows/ci.yml)
[![Binary cache](https://img.shields.io/badge/cache-cache.so1ve.dev-blue.svg)](https://cache.so1ve.dev/nix-cache-info)

## Packages

| Attribute | Documentation |
| --- | --- |
| `ab-download-manager` | [Usage](pkgs/ab-download-manager/README.md) |
| `alger-music-player` | [Upstream](https://github.com/algerkong/AlgerMusicPlayer) |
| `baidunetdisk` | [Upstream](https://pan.baidu.com/) |
| `baidupcs-go` | [Upstream](https://github.com/qjfoidnh/BaiduPCS-Go) |
| `bluez-5_86` | [Upstream](https://github.com/bluez/bluez) |
| `caddy-naive` | [Usage](pkgs/caddy-naive/README.md) |
| `cargo-pretty` | [Upstream](https://github.com/romancitodev/cargo-pretty) |
| `deepseek-harness` | [Usage](pkgs/deepseek-harness/README.md) |
| `dsh-plugins` | [Plugin catalog and updates](pkgs/dsh-plugins/README.md) |
| `dingtalk` | [Upstream](https://www.dingtalk.com/) |
| `firefoxpwa-xwayland` | [Usage](pkgs/firefoxpwa-xwayland/README.md) |
| `flutter-rust-bridge-codegen` | [Upstream](https://github.com/fzyzcjy/flutter_rust_bridge) |
| `gradle-language-server` | [Usage](pkgs/gradle-language-server/README.md) |
| `herdr` | [Upstream](https://github.com/herdrdev/herdr) |
| `kelivo` | [Upstream](https://github.com/Chevey339/kelivo) |
| `kotlin-lsp` | [Usage](pkgs/kotlin-lsp/README.md) |
| `magpie` | [Upstream](https://github.com/yetone/magpie) |
| `peazip-rar` | [Usage](pkgs/peazip-rar/README.md) |
| `pocket-id` | [Upstream](https://github.com/pocket-id/pocket-id) |
| `r-maple-mono-nf-cn` | [Usage](pkgs/r-maple-mono-nf-cn/README.md) |
| `rea` | [Usage](pkgs/rea/README.md) |
| `rime-frost` | [Upstream](https://github.com/gaboolic/rime-frost) |
| `rime-lmdg` | [Upstream](https://github.com/amzxyz/rime-wanxiang-data) |
| `rime-wanxiang` | [Upstream](https://github.com/amzxyz/rime-wanxiang) |
| `sunloginclient` | [Usage](pkgs/sunloginclient/README.md) |
| `waywallen` | [Usage](pkgs/waywallen/README.md) |
| `xwayland-satellite` | [Upstream](https://github.com/Supreeeme/xwayland-satellite) |
| `yanhekt-autoslides` | [Upstream](https://github.com/BIT-Admin/Yanhekt-AutoSlides) |
| `winboat-unstable` | [Usage](pkgs/winboat-unstable/README.md) |
| `yesplaymusic` | [Upstream](https://github.com/qier222/YesPlayMusic) |

## [NUR](https://github.com/nix-community/NUR)

### Package

```nix
environment.systemPackages = [
  pkgs.nur.repos.so1ve.ab-download-manager
];
```

### Home Manager module

```nix
imports = [
  inputs.nur.repos.so1ve.homeModules.ab-download-manager
];
```

## Flake

### Run or install

```bash
nix run github:so1ve/nur-packages#ab-download-manager
nix profile install github:so1ve/nur-packages#ab-download-manager
```

### Input

```nix
{
  inputs.so1ve.url = "github:so1ve/nur-packages";
}
```

### Overlay

```nix
{ inputs, pkgs, ... }:
{
  nixpkgs.overlays = [ inputs.so1ve.overlays.default ];
  environment.systemPackages = [ pkgs.so1ve.magpie ];
}
```

## Binary cache

Packages are stored in `ghcr.io/so1ve/nur-cache` and served through
[oranc](https://github.com/linyinfeng/oranc) at `https://cache.so1ve.dev`.

```nix
nix.settings = {
  extra-substituters = [ "https://cache.so1ve.dev" ];
  extra-trusted-public-keys = [
    "cache.so1ve.dev-1:SijyzF9iE/VZwMXgMpd/HrNX9iItDZ1tdiNdeGakQGY="
  ];
};
```

Other repositories can use the same upload action after installing Nix:

```yaml
permissions:
  contents: read
  packages: write
steps:
  - uses: so1ve/nur-packages/.github/actions/setup-cache@main
    if: github.event_name != 'pull_request'
    with:
      signing-key: ${{ secrets.ORANC_SIGNING_KEY }}
```

All projects upload to `ghcr.io/so1ve/nur-cache`. Set `ORANC_SIGNING_KEY` in each
uploading repository. The action uses its own locked oranc input and uploads new
store paths at the end of the job.

The `registry-token` input defaults to the workflow's `GITHUB_TOKEN`; grant the
repository write access in the GHCR package's **Manage Actions access** settings
to use it. Projects under another owner can pass a classic PAT with
`write:packages` access to the cache package instead:

```yaml
with:
  signing-key: ${{ secrets.ORANC_SIGNING_KEY }}
  registry-token: ${{ secrets.GHCR_CACHE_TOKEN }}
```

Use a separate PAT for each project so it can be rotated independently. Workflows
using a PAT do not need `packages: write` on their `GITHUB_TOKEN`. Downloads remain
anonymous through `https://cache.so1ve.dev` and use the signing public key above.

## Update package sources

```bash
nix run .#update
```
