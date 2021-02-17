## Up-to-date versions of yuzu and Ryujinx for nix
This NUR repo contains up to date versions of [Ryujinx](https://github.com/ryujinx/ryujinx), [yuzu-mainline](https://github.com/yuzu-emu/yuzu-mainline) and [yuzu-ea](https://github.com/pineappleEA/pineapple-src).
These packages take quite a while to compile, so I've set up a binary cache using [cachix](https://app.cachix.org/).

# Instructions
First of all, you should install the [NUR](https://github.com/nix-community/NUR).

Afterwards, enable this repository's binary cache. This hosts a precompiled binary of all packages.
```bash
nix run nixpkgs.cachix -c cachix use ivar
```

After this, you can start a shell with any packaged emulator, which will always be up-to-date.
```bash
nix-shell -p nur.repos.ivar.{ryujinx,yuzu-ea,yuzu-mainline}
```

Alternatively, in your [home-manager](https://github.com/nix-community/home-manager) configuration, put the following:
```nix
let
  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") { inherit pkgs; };
in {
...
home.packages = [
	nur.repos.ivar.ryujinx;
];
```
