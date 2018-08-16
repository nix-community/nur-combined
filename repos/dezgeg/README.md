# My personal packages for Nix User Repository

Here's various Nix expressions for stuff that (probably) isn't general enough to be included in Nixpkgs.

## kernelOrgToolchains

This set contains packages for the prebuilt kernel.org cross-compilation toolchains built by Arnd Bergmann.
These are all bare-metal toolchains that are only suitable for building Linux or U-Boot.
See https://mirrors.edge.kernel.org/pub/tools/crosstool/ for details.

## bootlinToolchains

This set contains packages for the prebuilt Bootlin cross-compilation toolchains.
These are more featureful than the kernel.org toolchains and include additional things like an userspace libc, C++ support and GDB.
See https://toolchains.bootlin.com/ for details.

## ubootDevShell

A `nix-shell` capable of building (nearly) every single U-Boot configuration.
Make sure to also install the `buildmanConfig` below to be able to use the `buildman` tool included in U-Boot.

## buildmanConfig

A configuration file (`~/.buildman`) for the `buildman` tool of U-Boot that uses the kernel.org toolchains for cross-compilation.
