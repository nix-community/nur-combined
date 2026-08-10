# zhyiheihei's NUR Packages

![Build and populate cache](https://github.com/zhyiheihei/zhyi-packages/workflows/Build%20and%20populate%20cache/badge.svg)

## About

This repository follows
[xddxdd/nur-packages](https://github.com/xddxdd/nur-packages) as its
upstream reference for project structure and workflows, and supplements
personal packages that are not natively available in nixpkgs.

Packages already provided by nixpkgs (such as seerr, freshrss, halo,
home-assistant, linkwarden, memos and metacubexd) are intentionally not
duplicated here.

## Binary Cache

Build artifacts are cached in the Attic binary cache:

```nix
{
  nix.settings.substituters = [ "https://attic.zhyi.xin/lantian" ];
  nix.settings.trusted-public-keys = [ "lantian:Pi7qMC8lIOrR8cTh4vfcRuSL/z+Bh5BAFYlEo/mbq2U=" ];
}
```

## How to use

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zhyi-packages = {
      url = "github:zhyiheihei/zhyi-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.zhyi-packages.nixosModules.setupOverlay
      ];
    };
  };
}
```

## Packages

<details>
<summary>Package set: (Uncategorized) (20 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
|  | `aioshutil` | [aioshutil](https://github.com/kumaraditya303/aioshutil) | 1.6 | Asynchronous shutil module |
|  | `cn2an` | [cn2an](https://github.com/Ailln/cn2an) | 0.5.24 | Convert Chinese numerals and Arabic numerals |
|  | `docker-proxy` | [docker-proxy](https://github.com/dqzboy/Docker-Proxy) | 5.1.3 | Self-hosted Docker registry proxy with host-based upstream routing |
|  | `docker-proxy-hubcmdui` | [docker-proxy-hubcmdui](https://github.com/dqzboy/Docker-Proxy) | 5.1.3 | Web management panel for the Docker-Proxy registry proxy |
|  | `filecodebox` | [filecodebox](https://github.com/vastsa/FileCodeBox) | 2.5.4 | Lightweight anonymous file sharing server with a FastAPI backend and Vue 3 theme |
|  | `jieba-next` | [jieba-next](https://github.com/mxcoras/jieba-next) | 1.0.0rc1 | Modern jieba fork with Rust speedups |
|  | `moviepilot` | [moviepilot](https://github.com/jxxghp/MoviePilot) | 2.15.5 | Media automation platform for downloads, organization, scraping and notifications |
|  | `nexus-media` | [nexus-media](https://github.com/linyuan0213/nexus-media) | 4.4.5 | Media library manager with automated downloading, media organization and subscription workflows |
|  | `nexus-media-web` | [nexus-media-web](https://github.com/linyuan0213/nexus-media-web) | 4.4.5 | Vue 3 web frontend for the Nexus Media media library manager |
|  | `pinyin2hanzi` | [Pinyin2Hanzi](https://github.com/someus/Pinyin2Hanzi) | 0.1.1 | Pinyin to Chinese character conversion engine |
|  | `proces` | [proces](https://github.com/Ailln/proces) | 0.1.7 | Text preprocess utilities |
|  | `pypika-tortoise` | [pypika-tortoise](https://github.com/tortoise/pypika-tortoise) | 0.6.5 | SQL query builder fork streamlined for tortoise-orm |
|  | `pyromark` | [pyromark](https://github.com/monosans/pyromark) | 0.9.13 | Blazingly fast Markdown parser |
|  | `sun-panel` | [sun-panel](https://github.com/hslr-s/sun-panel) | 1.8.1 | Server and NAS navigation panel, homepage, browser homepage |
|  | `telegramify-markdown` | [telegramify-markdown](https://github.com/sudoskys/telegramify-markdown) | 1.2.0 | Convert Markdown to Telegram plain text and entities |
|  | `torrentool` | [torrentool](https://github.com/idlesign/torrentool) | 1.2.0 | Tool to work with torrent files |
|  | `tortoise-orm` | [tortoise-orm](https://github.com/tortoise/tortoise-orm) | 0.25.3 | Easy async ORM for Python with relations in mind |
|  | `vaults3` | [vaults3](https://github.com/Kodiqa-Solutions/VaultS3) | 4.4.50 | Lightweight S3-compatible object storage with built-in web dashboard |
|  | `vertex` | [vertex](https://github.com/vertex-center/vertex) | 0.17.0 | Self-hosted lab manager for one-click container service installation |
|  | `zhconv-rs` | [zhconv-rs](https://github.com/Gowee/zhconv-rs) | 0.4.1 | Fast Chinese variant conversion backed by Rust |
</details>


<details>
<summary>Package set: python3Packages (11 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
|  | `python3Packages.aioshutil` | [aioshutil](https://github.com/kumaraditya303/aioshutil) | 1.6 | Asynchronous shutil module |
|  | `python3Packages.cn2an` | [cn2an](https://github.com/Ailln/cn2an) | 0.5.24 | Convert Chinese numerals and Arabic numerals |
|  | `python3Packages.jieba-next` | [jieba-next](https://github.com/mxcoras/jieba-next) | 1.0.0rc1 | Modern jieba fork with Rust speedups |
|  | `python3Packages.pinyin2hanzi` | [Pinyin2Hanzi](https://github.com/someus/Pinyin2Hanzi) | 0.1.1 | Pinyin to Chinese character conversion engine |
|  | `python3Packages.proces` | [proces](https://github.com/Ailln/proces) | 0.1.7 | Text preprocess utilities |
|  | `python3Packages.pypika-tortoise` | [pypika-tortoise](https://github.com/tortoise/pypika-tortoise) | 0.6.5 | SQL query builder fork streamlined for tortoise-orm |
|  | `python3Packages.pyromark` | [pyromark](https://github.com/monosans/pyromark) | 0.9.13 | Blazingly fast Markdown parser |
|  | `python3Packages.telegramify-markdown` | [telegramify-markdown](https://github.com/sudoskys/telegramify-markdown) | 1.2.0 | Convert Markdown to Telegram plain text and entities |
|  | `python3Packages.torrentool` | [torrentool](https://github.com/idlesign/torrentool) | 1.2.0 | Tool to work with torrent files |
|  | `python3Packages.tortoise-orm` | [tortoise-orm](https://github.com/tortoise/tortoise-orm) | 0.25.3 | Easy async ORM for Python with relations in mind |
|  | `python3Packages.zhconv-rs` | [zhconv-rs](https://github.com/Gowee/zhconv-rs) | 0.4.1 | Fast Chinese variant conversion backed by Rust |
</details>

<details>
<summary>Package set: uncategorized (9 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
|  | `uncategorized.docker-proxy` | [docker-proxy](https://github.com/dqzboy/Docker-Proxy) | 5.1.3 | Self-hosted Docker registry proxy with host-based upstream routing |
|  | `uncategorized.docker-proxy-hubcmdui` | [docker-proxy-hubcmdui](https://github.com/dqzboy/Docker-Proxy) | 5.1.3 | Web management panel for the Docker-Proxy registry proxy |
|  | `uncategorized.filecodebox` | [filecodebox](https://github.com/vastsa/FileCodeBox) | 2.5.4 | Lightweight anonymous file sharing server with a FastAPI backend and Vue 3 theme |
|  | `uncategorized.moviepilot` | [moviepilot](https://github.com/jxxghp/MoviePilot) | 2.15.5 | Media automation platform for downloads, organization, scraping and notifications |
|  | `uncategorized.nexus-media` | [nexus-media](https://github.com/linyuan0213/nexus-media) | 4.4.5 | Media library manager with automated downloading, media organization and subscription workflows |
|  | `uncategorized.nexus-media-web` | [nexus-media-web](https://github.com/linyuan0213/nexus-media-web) | 4.4.5 | Vue 3 web frontend for the Nexus Media media library manager |
|  | `uncategorized.sun-panel` | [sun-panel](https://github.com/hslr-s/sun-panel) | 1.8.1 | Server and NAS navigation panel, homepage, browser homepage |
|  | `uncategorized.vaults3` | [vaults3](https://github.com/Kodiqa-Solutions/VaultS3) | 4.4.50 | Lightweight S3-compatible object storage with built-in web dashboard |
|  | `uncategorized.vertex` | [vertex](https://github.com/vertex-center/vertex) | 0.17.0 | Self-hosted lab manager for one-click container service installation |
</details>

