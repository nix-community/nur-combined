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
| [3dstools-1.3.1](https://github.com/devkitpro/3dstools) | \_3dstools | Tools for 3DS homebrew |
| [bannertool-2024-11-30](https://github.com/ihaveamac/3ds-bannertool) | bannertool | A tool for creating 3DS banners. (Mix of Windows unicode fix and CMake build system) |
| [cleaninty-0.1.3](https://github.com/luigoalma/cleaninty) | cleaninty | Perform some Nintendo console client to server operations |
| [corgi3ds-2020-07-15](https://github.com/PSI-Rockin/Corgi3DS) | corgi3ds | An LLE dog-themed 3DS emulator |
| [ctrtool-1.2.1](https://github.com/3DSGuy/Project_CTR) | ctrtool | A tool to extract data from a 3ds rom |
| [cxitool-unstable-2019-04-10](https://github.com/devkitpro/3dstools) | cxitool | Convert 3dsx to CXI |
| [darctool-1.2.0](https://github.com/dnasdw/darctool) | darctool | A tool for extracting/creating darc file. |
| [discordwikibot-2024-12-20](https://github.com/stjohann/DiscordWikiBot) | discordwikibot | Discord bot for Wikimedia projects and MediaWiki wiki sites |
| [ftpd-3.2.1](https://github.com/mtheall/ftpd) | ftpd | FTP Server for 3DS/Switch (and Linux) |
| [kame-editor-1.4.1-unstable-2024-11-01](https://beelzy.gitlab.io/kame-editor/) | kame-editor | GUI frontend for kame-tools; makes custom 3DS themes. |
| [kame-tools-1.3.8-unstable-2024-11-01](https://gitlab.com/beelzy/kame-tools) | kame-tools | Fork of bannertools that includes tools for making 3DS themes. |
| [kwin-move-window-1.1.1](https://github.com/Merrit/kwin-move-window) | kwin-move-window | KWin script that adds shortcuts to move the active window with the keyboard |
| [launchcontrol-2.7](https://www.soma-zone.com/LaunchControl/) | launchcontrol | Create, manage and debug launchd(8) services |
| [lnshot-0.1.3](https://github.com/ticky/lnshot) | lnshot | Symlink your Steam screenshots to a sensible place |
| [makebax-2019-01-22](https://gitlab.com/Wolfvak/BAX) | makebax | BAX Animation creator |
| [makerom-0.18.4](https://github.com/3DSGuy/Project_CTR) | makerom | make 3ds roms |
| [mediawiki-1.39.11](https://www.mediawiki.org/) | mediawiki\_1\_39 | The collaborative editing software that runs Wikipedia |
| ~~[mediawiki-1.40.4](https://www.mediawiki.org/)~~ | ~~mediawiki\_1\_40~~ | ~~The collaborative editing software that runs Wikipedia~~ |
| ~~[mediawiki-1.41.5](https://www.mediawiki.org/)~~ | ~~mediawiki\_1\_41~~ | ~~The collaborative editing software that runs Wikipedia~~ |
| [mediawiki-1.42.4](https://www.mediawiki.org/) | mediawiki\_1\_42 | The collaborative editing software that runs Wikipedia |
| [mediawiki-1.43.0](https://www.mediawiki.org/) | mediawiki\_1\_43 | The collaborative editing software that runs Wikipedia |
| [mrpack-install-0.16.10-unstable-2024-11-24](https://github.com/nothub/mrpack-install) | mrpack-install | Modrinth Modpack server deployment |
| [otptool-1.0](https://github.com/SciresM/otptool) | otptool | view and extract data from a 3DS OTP |
| [rstmcpp-unstable-2023-04-02](https://gitlab.com/beelzy/rstmcpp) | rstmcpp | An experimental port of BrawlLib's RSTM encoder, and the WAV file handling from LoopingAudioConverter, to C++. |
| [rvthtool-dev-2024-12-15](https://github.com/GerbilSoft/rvthtool) | rvthtool | Open-source tool for managing RVT-H Reader consoles |
| [save3ds-unstable-2023-03-28](https://github.com/wwylele/save3ds) | save3ds | Extract/Import/FUSE for 3DS save/extdata/database. |
| [sd-format-linux-0.2.0](https://github.com/profi200/sdFormatLinux) | sd-format-linux | Properly format SD cards under Linux. |
| [themethod3-2024-04-20](https://github.com/DarkRTA/themethod3) | themethod3 | Tool for decrypting all mogg files used by the Rock Band series |
| [unxip-3.0](https://github.com/saagarjha/unxip) | unxip | A fast Xcode unarchiver |
| [wfs-tools-1.2.3-unstable-2024-12-06](https://github.com/koolkdev/wfs-tools) | wfs-tools | WFS (WiiU File System) Tools |
| [wifiboot-host-unstable-2023-07-02](https://github.com/danny8376/wifiboot-host) | wifiboot-host | command line version uploader for https://problemkaputt.de/wifiboot.htm |
| [xiv-on-mac-5.0.2](https://www.xivmac.com) | xiv-on-mac | Modern, open-source Final Fantasy XIV client for macOS |

## Overlay

The default overlay will add all the packages above in the `pkgs.hax` namespace, e.g. `pkgs.hax.save3ds`.

There is a NixOS module to automatically add this overlay as `nixosModules.overlay`. This module can also be used with Home Manager and nix-darwin.

## Home Manager modules

### services.lnshot.enable

Enables the lnshot daemon to automatically link Steam screenshots.

### services.lnshot.picturesName

Name of the directory to manage inside the Pictures folder. Defaults to "Steam Screenshots".
