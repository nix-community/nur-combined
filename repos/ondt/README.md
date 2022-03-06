# ondt's [Nix User Repository](https://github.com/nix-community/NUR)

![Build and populate cache](https://github.com/ondt/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-ondt-blue.svg)](https://ondt.cachix.org)


## Available packages
- [`nur.repos.ondt.lemonade`](https://github.com/Snowlabs/lemonade): A multithreaded alternative to [lemonbar](https://github.com/krypt-n/bar) written in rust
- [`nur.repos.ondt.csvlens`](https://github.com/YS-L/csvlens): Command line csv viewer
- [`nur.repos.ondt.ulozto-downloader`](https://github.com/setnicka/ulozto-downloader): Paralelní stahovač z Ulož.to s automatickým louskáním CAPTCHA kódů
- [`nur.repos.ondt.xss-events`](https://github.com/ondt/xss-events): Simple X11 ScreenSaver event listener
- [`nur.repos.ondt.xvisbell`](https://github.com/ondt/xvisbell): Visual Bell for X11

## Channels
- `channel:nixos-unstable`




# Adding the NUR repository
```nix
# /etc/nixos/configuration.nix
{
    nixpkgs.config.packageOverrides = pkgs: {
        nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
            inherit pkgs;
        };
    };
}
```





# Adding the NUR repository as a channel
```sh
sudo nix-channel --add https://github.com/nix-community/NUR/archive/master.tar.gz nur
sudo nix-channel --update
```
```nix
# /etc/nixos/configuration.nix
{
    nixpkgs.config.packageOverrides = pkgs: {
        nur = import <nur> {
            inherit pkgs;
        };
    };
}
```



# Adding the binary cache
```nix
# /etc/nixos/configuration.nix
{
    nix = {
        binaryCaches = [ "https://ondt.cachix.org" ];
        binaryCachePublicKeys = [ "ondt.cachix.org-1:bfVL4zF1qPjwrhAITTRqE7ZHEjNrBkqrb28ffYatMJk=" ];
    };
}
```




# Installing a package
```nix
# /etc/nixos/configuration.nix
{
    environment.systemPackages = with pkgs; [
        nur.repos.ondt.lemonade
    ];
}
```
