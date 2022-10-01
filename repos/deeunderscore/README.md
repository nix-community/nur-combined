# nur-packages

Some personal [Nix](https://nixos.org/) package expressions.

This repo is included in [NUR](https://github.com/nix-community/NUR); if you wish to use it through NUR, see the instructions in NUR's readme. 

If you are seeing this repo elsewhere, you can find the upstream at <https://github.com/DeeUnderscore/nur-packages>. This repo is based on [the nur-packages-template](https://github.com/nix-community/nur-packages-template). 

## Cachix
There is a Cachix cache available for these packages: <https://deeunderscore-nur.cachix.org>

## Packages
* **uniutils**: <http://billposer.org/Software/uniutils.html>
* **moar**: <https://github.com/walles/moar>
* **slit**: <https://github.com/tigrawap/slit>
* **faq**: <https://github.com/jzelinskie/faq>
* **git-archive-all**: <https://github.com/Kentzo/git-archive-all>
* **rdrview**: <https://github.com/eafer/rdrview>
* **libuiohook**: <https://github.com/kwhat/libuiohook>
* **input-overlay** (obs-input-overlay): <https://github.com/univrsal/input-overlay/>
* **moebius**: <https://blocktronics.github.io/moebius/>
* **linx-client**: <https://github.com/andreimarcu/linx-client>
* **nheko** (nheko-unstable): <https://nheko-reborn.github.io/>
* **mtxclient** (mtxclient-unstable): <https://github.com/Nheko-Reborn/mtxclient>
* **coeurl**: <https://nheko.im/nheko-reborn/coeurl>
* **pktriggercord**: <http://pktriggercord.melda.info/>
* **jday**: <http://jday.sourceforge.net/jday.html>

## Notes
### input-overlay
Hint: you can use `obs-input-overlay` from this package set as a plugin in `wrapOBS` from nixpkgs-unstable ahead of 21.05, or using Home Manager's `programs.obs-studio.plugins`, if available. 

### nheko
This is an unstable version of nheko (stable is available in nixpkgs)

### mtxclient 
This is an unstable version of mtxclient (stable is available in nixpkgs), to go with nheko-unstable