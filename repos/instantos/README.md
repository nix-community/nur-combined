
[![Build Status](https://travis-ci.org/instantOS/nix.svg?branch=master)](https://travis-ci.org/instantOS/nix)


# InstantOS Nix repository

[InstantOS](https://instantos.github.io/) packages for Nix. **InstaNtixOS** is a sub-repository to the [Nix User Repository (NUR)](https://github.com/nix-community/NUR). It is a community-maintained meta repository. In contrast to [Nixpkgs](https://github.com/nixos/nixpkgs), packages are built from source (currently, by hand and not always on time). They are not reviewed by any Nixpkgs member.

![InsaNtixOS](https://user-images.githubusercontent.com/11145016/87154656-e2ead300-c2b9-11ea-941d-e743ade87910.png)

# Usage

To install, clone the repository, then inside it run:

```nix
nix-env -iA instantixos -f default.nix --arg pkgs 'import <nixpkgs> {}'
```

The last argument "`--arg`" causes the build to run from your version of [nixpkgs](https://github.com/nixos/nixpkgs)
rather than the fixed commit of the last tagged stable version.
If you want to take of a stable build that likely has a lot of its components cached, you should ommit the that
last part.

After installation, you can run `instantwm`, just as you would any other window manager.
For many people that means putting `startinstantos` in your `~/.xinitrc`.
See an example in `./utils/xinitrc`
You can also find an example NixOS configuration in `./utils/configuration.nix`.

# Usage via NUR

Accessing NUR can be done easily. Just add the following to `~/.config/nixpkgs/config.nix`:

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

Then you can add `nur.repos.instantos.PACKAGE_NAME` to your `configuration.nix` or install **InstantOs** packages via:

```console
$ nix-env -f '<nixpkgs>' -iA nur.repos.instantos.PACKAGE_NAME
```
# Faster installation with cachix

You may want to install cachix and take advante of the build artefact caching with:

```console
$ nix-env -iA cachix -f https://cachix.org/api/v1/install
$ cachix use instantos
```

[![Build Status](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages.svg?branch=master)](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages)
[![Cachix Cache](https://img.shields.io/badge/cachix-instantos-blue.svg)](https://instantos.cachix.org)
