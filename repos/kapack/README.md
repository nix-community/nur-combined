 # Kapack [NUR](https://github.com/nix-community/NUR) repository

Basic usage
-----------

* To make NUR accessible for your login user, add the following to `~/.config/nixpkgs/config.nix`:

```nix
{
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
}
```

* For NixOS add the following to your `/etc/nixos/configuration.nix`:

```nix
{
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
}
```

* Install a package

```console
$ nix-env -iA -f "<nixpkgs>" nur.repos.kapack.pybatsim
```

[![Build Status](https://travis-ci.com/oar-team/nur-kapack.svg?branch=master)](https://travis-ci.com/oar-team/nur-kapack)
[![Cachix Cache](https://img.shields.io/badge/cachix-kapack-blue.svg)](https://kapack.cachix.org)

