# nur-packages

![Build and populate cache](https://github.com/ihaveamac/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg) [![Cachix Cache](https://img.shields.io/badge/cachix-ihaveahax-blue.svg)](https://ihaveahax.cachix.org)

My personal [NUR](https://github.com/nix-community/NUR) repository.

Darwin/macOS builds are manually pushed by me to cachix occasionally. Usually when I also update flake.lock.

NUR link: https://nur.nix-community.org/repos/ihaveamac/

## Packages

| Name | Attr | Description |
| --- | --- | --- |
| [3dslink-0.6.3](https://github.com/devkitPro/3dslink) | \_3dslink | Send 3DSX files to the Homebrew Launcher on 3DS |
| [3dstool-1.2.6](https://github.com/dnasdw/3dstool) | \_3dstool | An all-in-one tool for extracting/creating 3ds roms. |
| [cleaninty-0.1.3](https://github.com/luigoalma/cleaninty) | cleaninty | Perform some Nintendo console client to server operations |
| [corgi3ds-2020-07-15](https://github.com/PSI-Rockin/Corgi3DS) | corgi3ds | An LLE dog-themed 3DS emulator |
| [ctrtool-1.2.0](https://github.com/3DSGuy/Project_CTR) | ctrtool | A tool to extract data from a 3ds rom |
| [darctool-1.2.0](https://github.com/dnasdw/darctool) | darctool | A tool for extracting/creating darc file. |
| [discordwikibot-2024-11-11](https://github.com/stjohann/DiscordWikiBot) | discordwikibot | Discord bot for Wikimedia projects and MediaWiki wiki sites |
| [ftpd-3.2.1](https://github.com/mtheall/ftpd) | ftpd | FTP Server for 3DS/Switch (and Linux) |
| [kwin-move-window-1.1.1](https://github.com/Merrit/kwin-move-window) | kwin-move-window | KWin script that adds shortcuts to move the active window with the keyboard |
| [lnshot-0.1.3](https://github.com/ticky/lnshot) | lnshot | Symlink your Steam screenshots to a sensible place |
| [makebax-2019-01-22](https://gitlab.com/Wolfvak/BAX) | makebax | BAX Animation creator |
| [makerom-0.18.4](https://github.com/3DSGuy/Project_CTR) | makerom | make 3ds roms |
| [mediawiki-1.39.10](https://www.mediawiki.org/) | mediawiki\_1\_39 | The collaborative editing software that runs Wikipedia |
| [mediawiki-1.40.4](https://www.mediawiki.org/) | mediawiki\_1\_40 | The collaborative editing software that runs Wikipedia |
| [mediawiki-1.41.4](https://www.mediawiki.org/) | mediawiki\_1\_41 | The collaborative editing software that runs Wikipedia |
| [mediawiki-1.42.3](https://www.mediawiki.org/) | mediawiki\_1\_42 | The collaborative editing software that runs Wikipedia |
| [mediawiki-1.43.0-rc.0](https://www.mediawiki.org/) | mediawiki\_1\_43 | The collaborative editing software that runs Wikipedia |
| [rvthtool-dev-2024-05-17](https://github.com/GerbilSoft/rvthtool) | rvthtool | Open-source tool for managing RVT-H Reader consoles |
| [save3ds-dev-2023-03-28](https://github.com/wwylele/save3ds) | save3ds | Extract/Import/FUSE for 3DS save/extdata/database. |
| [sd-format-linux-0.2.0](https://github.com/profi200/sdFormatLinux) | sd-format-linux | Properly format SD cards under Linux. |
| [themethod3-2024-04-20](https://github.com/DarkRTA/themethod3) | themethod3 | Tool for decrypting all mogg files used by the Rock Band series |
| [unxip-3.0](https://github.com/saagarjha/unxip) | unxip | A fast Xcode unarchiver |

## Home Manager modules

### services.lnshot.enable

Enables the lnshot daemon to automatically link Steam screenshots.

### services.lnshot.picturesName

Name of the directory to manage inside the Pictures folder. Defaults to "Steam Screenshots".
