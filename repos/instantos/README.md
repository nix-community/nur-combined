<div align="center">
    <h1>instantNIX</h1>
    <p>instantOS port to Nix</p>
    <img width="300" height="300" src="https://raw.githubusercontent.com/instantOS/instantLOGO/master/png/nix.png">
</div>

-------
[![Build Status](https://travis-ci.org/instantOS/instantNIX.svg?branch=master)](https://travis-ci.org/instantOS/instantNIX)

[InstantOS](https://instantos.github.io/) window manager and tools packaged for Nix.

[![InstantOS beta5 preview](https://img.youtube.com/vi/zqcEv3bdIAM/0.jpg)](http://www.youtube.com/watch?v=zqcEv3bdIAM)

**InstantNix** is a sub-repository to the [Nix User Repository (NUR)](https://github.com/nix-community/NUR).
It is a community-maintained meta-repository and **not** part of [Nixpkgs](https://github.com/nixos/nixpkgs) (yet).

Please note, that our parent project instantOS is still in beta phase, 
and we are even more so.
Not everything will work out of the box and some extra setup might be required.
That being said, we've never had a change that broke startup and basic functionality.
Knock on wood!
We will strive to get InstantNIX into [Nixpkgs](https://github.com/nixos/nixpkgs),
the official Nix package repository, soon after instantOS releases its version 1.0.
Then NUR-acrobatics will no longer be required.

# Usage

Detailed instructions on how to install and use instantOS tools with Nix or
on NixOS can be found in the [instantNix Wiki](https://github.com/instantOS/instantNIX/wiki).
In this Readme we only give you a very quick overview.
Currently there are two methods, installing from the Nix User Repository (NUR)
or cloning the repo.

In both cases, first [install Nix](https://nixos.org/nix/manual/#chap-installation)
on your system if not already installed.

```console
curl -L https://nixos.org/nix/install | sh
``` 

# Installation from Clone

Clone this repository and change directory into it.
From there, run:

```nix
nix-env -iA instantnix -f default.nix --arg pkgs 'import <nixpkgs> {}'
```

The last part, starting at "`--arg`" is recommended.
It causes the build to run from your version of
[nixpkgs](https://github.com/nixos/nixpkgs)
rather than the fixed commit of the last tagged stable version,
which can be up to six month old.

After installation, you can run `instantwm`,
just as you would run [dwm](https://dwm.suckless.org) on your system.
For many people that means putting `startinstantos` in your `~/.xinitrc`.
See an example in `./utils/xinitrc`.

Some related resources:
 - [dwm on ubuntu](https://cannibalcandy.wordpress.com/2012/04/26/installing-and-configuring-dwm-under-ubuntu/)
 - [dwm on lightdm](https://blkct.wordpress.com/2017/06/16/how-to-start-dwm-from-lightdm/)

Note: Some additional configuration steps such as installing optional software
or setting the correct UID for instantLOCK might be required for everything to
work.
Permissions are an issue on some systems.

# Installation via NUR

Accessing NUR can be done easily.
Just add the following to `~/.config/nixpkgs/config.nix`:

```nix
{
  packageOverrides = pkgs: {
  # For nixos' `configuration.nix`, replace above line by:
  #nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
}
```

Then you can add `nur.repos.instantos.PACKAGE_NAME` to your `configuration.nix`
or install **InstantOs** packages via:

```console
$ nix-env -f '<nixpkgs>' -iA nur.repos.instantos.PACKAGE_NAME  # "nur.repos.instantos.instantnix" for all the instantOS packages
```

# Faster installation with cachix

You may want to install cachix and take advantage of the build artefact caching with:

```console
$ nix-env -iA cachix -f https://cachix.org/api/v1/install
$ cachix use instantos
```

That way Nix does not compile as much from source and rather uses pre-compiled
packages from [cachix](https://cachix.org).

[![Cachix Cache](https://img.shields.io/badge/cachix-instantos-blue.svg)](https://instantos.cachix.org)
