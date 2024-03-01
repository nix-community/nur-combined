# NUR repository NL-TCH
## packages in repository:

1. spotify-adblock
using https://github.com/abba23/spotify-adblock and https://github.com/dasJ/spotifywm/
Listen to spotify without banner ads and interupting audio ads
2. ~~ciscoPacketTracer8 This version of packettracer8 automatically installs the required .deb from a private and fast nextcloud server, instead of the slow public link.~~ **_Deprecated_**

## how to install
1. Add the following lines to your `/etc/nixos/configuration.nix`
```nix
nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
```
2. Specify the packages you want to install from my repository in your `/etc/nixos/configuration.nix`
```nix
environment.systemPackages = with pkgs; [
   nur.repos.nltch.spotify-adblock    #for installing spotify-adblock
]
```
3. run `nixos-rebuild switch` to download, compile and install the packages 

# nur-packages


<!-- Remove this if you don't use github actions -->
![Build and populate cache](https://github.com/NL-TCH/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-nltch-blue.svg)](https://nltch.cachix.org)

