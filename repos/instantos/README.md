# InstantOS Nix repository

[InstantOS](https://instantos.github.io/) packages for Nix. **InstaNtixOS** is a sub-repository to the [Nix User Repository (NUR)](https://github.com/nix-community/NUR). It is a community-maintained meta repository. In contrast to [Nixpkgs](https://github.com/nixos/nixpkgs), packages are built from source (currently, by hand and not always on time). They are not reviewed by any Nixpkgs member.

![InsaNtixOS](https://user-images.githubusercontent.com/11145016/87154656-e2ead300-c2b9-11ea-941d-e743ade87910.png)

# Usage

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

You may want to install cachix and take advante of the build artefact caching with:

```console
$ nix-env -iA cachix -f https://cachix.org/api/v1/install
$ cachix use instantos
```

[![Build Status](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages.svg?branch=master)](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages)
[![Cachix Cache](https://img.shields.io/badge/cachix-instantos-blue.svg)](https://instantos.cachix.org)


