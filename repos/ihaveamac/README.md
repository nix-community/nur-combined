# nur-packages

![Build and populate cache](https://github.com/ihaveamac/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg) [![Cachix Cache](https://img.shields.io/badge/cachix-ihaveahax-blue.svg)](https://ihaveahax.cachix.org)

My personal [NUR](https://github.com/nix-community/NUR) repository.

Darwin/macOS builds are manually pushed by me to cachix occasionally. Usually when I also update flake.lock.

## Packages

Attributes listed on [the NUR](https://nur.nix-community.org/repos/ihaveamac/)

* 3dstool-1.2.6 (as \_3dstool attribute)
* lnshot-0.1.3
* save3ds-dev-2023-03-28
* cleaninty-0.1.3
* rvthtool-dev-2024-05-17
* themethod3-2024-04-20
* makebax-2019-01-22
* ctrtool-1.2.0
* makerom-0.18.4
* kwin-move-window-1.1.1
* mediawiki-1.39.10
* mediawiki-1.40.4
* mediawiki-1.41.4
* mediawiki-1.42.3
* mediawiki-1.43.0-rc.0
* 3dslink-0.6.3 (as \_3dslink attribute)
* discordwikibot-2024-11-11
* sd-format-linux-0.2.0
* unxip-3.0
* corgi3ds-2020-07-15
* ftpd-3.2.1
* darctool-1.2.0

## Home Manager modules

### services.lnshot.enable

Enables the lnshot daemon to automatically link Steam screenshots.

### services.lnshot.picturesName

Name of the directory to manage inside the Pictures folder. Defaults to "Steam Screenshots".
