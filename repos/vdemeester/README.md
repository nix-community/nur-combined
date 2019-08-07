# Nur-packages [![Build Status](https://travis-ci.com/vdemeester/nur-packages.svg?branch=master)](https://travis-ci.com/vdemeester/nur-packages)

My personal NUR repository. Here is a small guide to build some
package.

```shell
## Build with current system nixpkgs
# build ape
nix-build . -A ape
# build ko
nix-build . -A ko
## Build with nixos-19.03 channel
# build ape
nix-build . -A allTargets.nixos-19_03.ape
# build ape
nix-build . -A allTargets.nixos-19_03.ko
# build all
nix-build . -A allTargets.nixos-19_03
## Build with nixos-unstable channel
# build ape
nix-build . -A allTargets.nixos-unstable.ape
# build ape
nix-build . -A allTargets.nixos-unstable.ko
# build all
nix-build . -A allTargets.nixos-unstable
```
