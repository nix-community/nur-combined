# nur-tox

**A [NUR](https://github.com/nix-community/NUR) repository of the tox-rs project**

[![Build Status](https://travis-ci.org/tox-rs/nur-tox.svg?branch=master)](https://travis-ci.org/tox-rs/nur-tox)
[![Cachix Cache](https://img.shields.io/badge/cachix-tox-blue.svg)](https://tox.cachix.org)

## Usage

To install packages from this repo, add the following to `configuration.nix`:

```nix
{
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
}
```

Then packages will be available as `nixos.nur.repos.tox.<package name>`.

### Running a tox node

Add the following to `configuration.nix`:

```nix
let
  nur-no-pkgs = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {};
in
{
  imports =
    [
      nur-no-pkgs.repos.tox.modules.tox-node
    ];

    services.tox-node.enable = true;
}
```
