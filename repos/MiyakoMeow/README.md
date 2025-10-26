# **[MiyakoMeow](https://github.com/MiyakoMeow)'s personal [NUR](https://github.com/nix-community/NUR) repository**

## Usage

- `flake.nix`:

```nix
inputs = {
  # NixOS 官方软件源，这里使用 nixos-25.05 分支
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  nur-miyakomeow = {
    url = "github:MiyakoMeow/nur-packages";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

- (Optional) Add Cache Server in `configuration.nix`:

```nix
nix.settings = {
  # Use Flake & Nix Commands
  experimental-features = ["nix-command" "flakes"];
  substituters = [
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://nix-community.cachix.org"
    "https://miyakomeow.cachix.org"
  ];
  trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "miyakomeow.cachix.org-1:85k7pjjK1Voo+kMHJx8w3nT1rlBow3+4/M+LsAuMCRY="
  ];
};
```

- Install a pack in `configuration.nix`:

```nix
environment.systemPackages = with pkgs; let
  nur-miyakomeow = inputs.nur-miyakomeow.packages.${pkgs.system};
in [
  nur-miyakomeow.liberica-jdk-21
];
```

- Or Use `nixpkgs.overlay`:

```nix
# nixpkgs设置
nixpkgs = {
  config = {
    # 可选：允许非自由软件
    allowUnfree = true;
  };
  overlays = [
    # NUR
    inputs.nur.overlays.default
    # MiyakoMeow's NUR Repo
    (final: prev: {
      nur-miyakomeow = import inputs.nur-miyakomeow {
        # 关键点：使用当前系统的配置，使上述config能够生效
        pkgs = prev;
      };
    })
  ];
};

environment.systemPackages = with pkgs.nur-miyakomeow; [
  liberica-jdk-21 
];
```

## Status

<!-- Remove this if you don't use github actions -->
![Build and populate cache](https://github.com/MiyakoMeow/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

<!--
Uncomment this if you use travis:

[![Build Status](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages.svg?branch=master)](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages)
-->
[![Cachix Cache](https://img.shields.io/badge/cachix-miyakomeow-blue.svg)](https://miyakomeow.cachix.org)

## Package List


<!-- BEGIN_PACKAGE_LIST -->

This section is auto-generated. Do not edit manually.

### by-name

| useable-path | version | description |
| --- | --- | --- |
| `baidunetdisk` | [4.17.7](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/by-name/ba/baidunetdisk/package.nix) | [🏠Homepage](https://pan.baidu.com/) 百度网盘 Linux 客户端 |
| `beatoraja` | [0.8.8](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/by-name/be/beatoraja/package.nix) | [🏠Homepage](https://www.mocha-repository.info/download.php) A modern BMS Player |
| `clang-minimal` | [21.1.1](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/by-name/cl/clang-minimal/package.nix) | [🏠Homepage](https://clang.llvm.org/) C language family frontend for LLVM (wrapper script) |
| `continue-cli` | [1.4.45](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/by-name/co/continue-cli/package.nix) | [🏠Homepage](https://continue.dev) Continue CLI |
| `fcitx5-pinyin-moegirl` | [20250309](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/by-name/fc/fcitx5-pinyin-moegirl/package.nix) | [🏠Homepage](https://github.com/outloudvi/mw2fcitx) Fcitx 5 pinyin dictionary generator for MediaWiki instances. Releases for dict of zh.moegirl.org.cn. (auto update) |
| `fcitx5-pinyin-zhwiki` | [0.2.5](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/by-name/fc/fcitx5-pinyin-zhwiki/package.nix) | [🏠Homepage](https://github.com/felixonmars/fcitx5-pinyin-zhwiki) Fcitx 5 Pinyin Dictionary from zh.wikipedia.org (auto update) |
| `free-download-manager` | [6.30.1.6471](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/by-name/fr/free-download-manager/package.nix) | [🏠Homepage](https://www.freedownloadmanager.org/) FDM is a powerful modern download accelerator and organizer. |
| `hn-linux-client` | [V2-64](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/by-name/hn/hn-linux-client/package.nix) | [🏠Homepage](http://222.246.130.17:37209/) HN Linux Client, for net interface of China Telecom in HUNAN University |
| `jportaudio` | [0-unstable-2025-10-24](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/by-name/jp/jportaudio/package.nix) | [🏠Homepage](https://github.com/philburk/portaudio-java) Java wrapper for PortAudio audio library |
| `lampghost` | [0.3.1](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/by-name/la/lampghost/package.nix) | [🏠Homepage](https://github.com/Catizard/lampghost) [📝Changelog](https://github.com/Catizard/lampghost/releases/tag/v0.3.1) Offline & Cross-platform beatoraja lamp viewer and more |
| `lampghost-dev` | [0.3.1-unstable-2025-10-22](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/by-name/la/lampghost-dev/package.nix) | [🏠Homepage](https://github.com/Catizard/lampghost) [📝Changelog](https://github.com/Catizard/lampghost/commits/main) Offline & Cross-platform beatoraja lamp viewer and more |
| `mbmconfig` | [3.24.0824.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/by-name/mb/mbmconfig/package.nix) | [🏠Homepage](https://mistyblue.info) mBMconfig - GUI configuration tool for mBMplay (runs via Wine) |
| `mbmplayer` | [3.24.0824.1](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/by-name/mb/mbmplayer/package.nix) | [🏠Homepage](https://mistyblue.info) mBMplay - BMS 播放器 (通过 Wine 运行) |
| `pbmsc` | [3.5.5.16](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/by-name/pb/pbmsc/package.nix) | [🏠Homepage](https://github.com/psyk2642/iBMSC) pBMSC (iBMSC Windows build) packaged to run with Wine |

### grub-themes

| useable-path | version | description |
| --- | --- | --- |
| `grub-themes.13atm01-collection.airani-iofifteen` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'airani-iofifteen' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.artoria-pendragon-15th-celebration-version` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'artoria-pendragon-15th-celebration-version' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.artoria-pendragon-lancer-version` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'artoria-pendragon-lancer-version' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.artoria-pendragon-maid-version` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'artoria-pendragon-maid-version' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.doki-doki-literature-club-chibi-version` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'doki-doki-literature-club-chibi-version' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.hatsune-miku` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'hatsune-miku' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.hoshimati-suisei` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'hoshimati-suisei' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.ichika-christmas-version` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'ichika-christmas-version' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.illyasviel-von-einzbern` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'illyasviel-von-einzbern' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.illyasviel-von-einzbern-maid-version` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'illyasviel-von-einzbern-maid-version' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.inoue-takina` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'inoue-takina' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.itsuki-christmas-version` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'itsuki-christmas-version' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.kobo-kanaeru` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'kobo-kanaeru' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.kurumi` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'kurumi' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.leonardo-da-vinci` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'leonardo-da-vinci' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.leonardo-da-vinci-rider-version` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'leonardo-da-vinci-rider-version' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.mash-kyrielight-version-1` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'mash-kyrielight-version-1' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.mash-kyrielight-version-2` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'mash-kyrielight-version-2' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.matou-sakura-15th-celebration-version` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'matou-sakura-15th-celebration-version' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.matou-sakura-maid-version` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'matou-sakura-maid-version' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.miku-christmas-version` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'miku-christmas-version' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.monika-doki-doki-literature-club` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'monika-doki-doki-literature-club' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.nakano-ichika` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'nakano-ichika' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.nakano-itsuki` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'nakano-itsuki' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.nakano-miku` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'nakano-miku' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.nakano-nino` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'nakano-nino' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.nakano-yotsuba` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'nakano-yotsuba' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.natsuki-doki-doki-literature-club` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'natsuki-doki-doki-literature-club' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.nino-christmas-version` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'nino-christmas-version' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.nishikigi-chisato` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'nishikigi-chisato' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.okita-souji-alter-version` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'okita-souji-alter-version' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.okita-souji-version-1` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'okita-souji-version-1' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.okita-souji-version-2` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'okita-souji-version-2' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.sayori-doki-doki-literature-club` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'sayori-doki-doki-literature-club' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.tohsaka-rin-15th-celebration-version` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'tohsaka-rin-15th-celebration-version' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.tohsaka-rin-maid-version` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'tohsaka-rin-maid-version' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.touhou-project` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'touhou-project' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.yotsuba-christmas-version` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'yotsuba-christmas-version' from 13atm01/GRUB-Theme |
| `grub-themes.13atm01-collection.yuri-doki-doki-literature-club` | [Lyco-v1.0](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/13atm01-collection/default.nix) | [🏠Homepage](https://github.com/13atm01/GRUB-Theme) GRUB2 theme 'yuri-doki-doki-literature-club' from 13atm01/GRUB-Theme |
| `grub-themes.star-rail.acheron` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (acheron) |
| `grub-themes.star-rail.acheron_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (acheron_cn) |
| `grub-themes.star-rail.aglaea` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (aglaea) |
| `grub-themes.star-rail.aglaea_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (aglaea_cn) |
| `grub-themes.star-rail.anaxa` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (anaxa) |
| `grub-themes.star-rail.anaxa_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (anaxa_cn) |
| `grub-themes.star-rail.archer` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (archer) |
| `grub-themes.star-rail.archer_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (archer_cn) |
| `grub-themes.star-rail.argenti` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (argenti) |
| `grub-themes.star-rail.argenti_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (argenti_cn) |
| `grub-themes.star-rail.aventurine` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (aventurine) |
| `grub-themes.star-rail.aventurine_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (aventurine_cn) |
| `grub-themes.star-rail.blackswan` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (blackswan) |
| `grub-themes.star-rail.blackswan_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (blackswan_cn) |
| `grub-themes.star-rail.boothill` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (boothill) |
| `grub-themes.star-rail.boothill_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (boothill_cn) |
| `grub-themes.star-rail.castorice` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (castorice) |
| `grub-themes.star-rail.castorice_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (castorice_cn) |
| `grub-themes.star-rail.cerydra` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (cerydra) |
| `grub-themes.star-rail.cerydra_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (cerydra_cn) |
| `grub-themes.star-rail.cipher` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (cipher) |
| `grub-themes.star-rail.cipher_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (cipher_cn) |
| `grub-themes.star-rail.dr_ratio` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (dr_ratio) |
| `grub-themes.star-rail.dr_ratio_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (dr_ratio_cn) |
| `grub-themes.star-rail.evernight` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (evernight) |
| `grub-themes.star-rail.evernight_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (evernight_cn) |
| `grub-themes.star-rail.feixiao` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (feixiao) |
| `grub-themes.star-rail.feixiao_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (feixiao_cn) |
| `grub-themes.star-rail.firefly` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (firefly) |
| `grub-themes.star-rail.firefly_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (firefly_cn) |
| `grub-themes.star-rail.fugue` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (fugue) |
| `grub-themes.star-rail.fugue_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (fugue_cn) |
| `grub-themes.star-rail.hanya` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (hanya) |
| `grub-themes.star-rail.hanya_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (hanya_cn) |
| `grub-themes.star-rail.huohuo` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (huohuo) |
| `grub-themes.star-rail.huohuo_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (huohuo_cn) |
| `grub-themes.star-rail.hyacine` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (hyacine) |
| `grub-themes.star-rail.hyacine_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (hyacine_cn) |
| `grub-themes.star-rail.hysilens` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (hysilens) |
| `grub-themes.star-rail.hysilens_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (hysilens_cn) |
| `grub-themes.star-rail.jade` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (jade) |
| `grub-themes.star-rail.jade_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (jade_cn) |
| `grub-themes.star-rail.jiaoqiu` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (jiaoqiu) |
| `grub-themes.star-rail.jiaoqiu_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (jiaoqiu_cn) |
| `grub-themes.star-rail.jingliu` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (jingliu) |
| `grub-themes.star-rail.jingliu_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (jingliu_cn) |
| `grub-themes.star-rail.kafka` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (kafka) |
| `grub-themes.star-rail.kafka_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (kafka_cn) |
| `grub-themes.star-rail.lingsha` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (lingsha) |
| `grub-themes.star-rail.lingsha_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (lingsha_cn) |
| `grub-themes.star-rail.luocha` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (luocha) |
| `grub-themes.star-rail.luocha_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (luocha_cn) |
| `grub-themes.star-rail.march7th-thehunt` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (march7th-thehunt) |
| `grub-themes.star-rail.march7th-thehunt_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (march7th-thehunt_cn) |
| `grub-themes.star-rail.mydei` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (mydei) |
| `grub-themes.star-rail.mydei_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (mydei_cn) |
| `grub-themes.star-rail.phainon` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (phainon) |
| `grub-themes.star-rail.phainon_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (phainon_cn) |
| `grub-themes.star-rail.rappa` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (rappa) |
| `grub-themes.star-rail.rappa_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (rappa_cn) |
| `grub-themes.star-rail.robin` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (robin) |
| `grub-themes.star-rail.robin_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (robin_cn) |
| `grub-themes.star-rail.ruanmei` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (ruanmei) |
| `grub-themes.star-rail.ruanmei_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (ruanmei_cn) |
| `grub-themes.star-rail.saber` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (saber) |
| `grub-themes.star-rail.saber_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (saber_cn) |
| `grub-themes.star-rail.sparkle` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (sparkle) |
| `grub-themes.star-rail.sparkle_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (sparkle_cn) |
| `grub-themes.star-rail.sunday` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (sunday) |
| `grub-themes.star-rail.sunday_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (sunday_cn) |
| `grub-themes.star-rail.sushang` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (sushang) |
| `grub-themes.star-rail.sushang_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (sushang_cn) |
| `grub-themes.star-rail.theherta` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (theherta) |
| `grub-themes.star-rail.theherta_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (theherta_cn) |
| `grub-themes.star-rail.tribbie` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (tribbie) |
| `grub-themes.star-rail.tribbie_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (tribbie_cn) |
| `grub-themes.star-rail.yunli` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (yunli) |
| `grub-themes.star-rail.yunli_cn` | [20250927-065308](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/star-rail/package.nix) | [🏠Homepage](https://github.com/voidlhf/StarRailGrubThemes) Honkai: Star Rail GRUB theme (yunli_cn) |
| `grub-themes.suisei` | [0-unstable-2024-11-01](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/grub-themes/suisei/package.nix) | [🏠Homepage](https://github.com/kirakiraAZK/suiGRUB) suiGRUB |

### ros2

| useable-path | version | description |
| --- | --- | --- |
| `ros2.ros-dev-tools` | [0-unstable-2025-03-13](https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/ros2/ros-dev-tools/package.nix) | [🏠Homepage](https://github.com/DSPEngineer/ros-dev-tools) ROS development tools with Docker integration |

<!-- END_PACKAGE_LIST -->