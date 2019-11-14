 # GRICAD [NUR](https://github.com/nix-community/NUR) repository

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

* Install a package

```console
$ nix-env -iA -f "<nixpkgs>" nur.repos.gricad.openmpi2-opa
```

Advanced usage (mostly for admins)
----------------------------------

* Local build of a package:

```
nix-build --arg pkgs 'import <nixpkgs> {}' -A hello
```

* Optional pushing into the cache (need gricad cachix key)

```
nix-build --arg pkgs 'import <nixpkgs> {}' -A hello | cachix push gricad
```

* Force an update of the repository

```
curl -XPOST https://nur-update.herokuapp.com/update?repo=gricad
```

* Configure cachix on a cluster
  * Login as root and load nix environment
  * Install cachix: `nix-env -iA cachix -f https://cachix.org/api/v1/install`
  * Activate cachix: `cachix use gricad`

[![Build Status](https://travis-ci.com/Gricad/nur-packages.svg?branch=master)](https://travis-ci.com/Gricad/nur-packages)
[![Cachix Cache](https://img.shields.io/badge/cachix-gricad-blue.svg)](https://gricad.cachix.org)


