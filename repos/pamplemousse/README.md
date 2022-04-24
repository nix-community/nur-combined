# nur-packages

**Superseded by https://github.com/Pamplemousse/nix-utils**

---

**My personal [NUR](https://github.com/nix-community/NUR) repository**

[![Build Status](https://travis-ci.org/Pamplemousse/nur-packages.svg?branch=master)](https://travis-ci.org/Pamplemousse/nur-packages)
[![Cachix Cache](https://img.shields.io/badge/cachix-Pamplemousse-blue.svg)](https://pamplemousse.cachix.org)


## Develop

To test locally, make sure you have the following in your `~/.config/nixpkgs/config.nix`:
```nix
{
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;

      repoOverrides = {
        pamplemousse = import <PATH TO LOCAL NUR>/default.nix { inherit pkgs; };
      };
    };
  };
}
```

Then you can build / test the packages added with:
```bash
$ nix-shell -p nur.repos.pamplemousse.<PACKAGE>
```
