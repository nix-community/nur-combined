# bhipple nur-packages

**My personal [NUR] repository**

## Quick Start
To build something out of this, install the [NUR] overlay as described upstream, then:

```
cd ~/src/nixpkgs
nix build -Lvf '<nixos>' nur.repos.bhipple.plaid2qif
```

To build using locally modified NUR expressions after cloning this, I have my
`config.nix` `packageOverrides` setup to make this work:

```
nix build -Lvf '<nixos>' bhipple.plaid2qif
```


[![Build Status](https://travis-ci.com/bhipple/nur-packages.svg?branch=master)](https://travis-ci.com/bhipple/nur-packages)
[NUR]: https://github.com/nix-community/NUR
