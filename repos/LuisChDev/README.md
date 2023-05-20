# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/LuisChDev/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix-luischdev-blue.svg)](https://luischdev.cachix.org)

The Whitesur-kde theme is largely untested, I only use the SDDM theme. Try it
and if problems arise, I'll be glad to help :)

# NordVPN

nordVPN consists of a package and module. in order for it to work, you need to
make the package in the repo available on your `nixpkgs` via `packageOverrides`.
Note that you'll have to also set `networking.firewall.checkReversePath =
false;`, add UDP 1194 and TCP 443 to the list of allowed ports in the firewall
and add your user to the "nordvpn" group (`users.users.<username>.extraGroups`):

```
{ config, pkgs, ... }:
let
  nur-no-pkgs = import (builtins.fetchTarball
    "https://github.com/nix-community/NUR/archive/master.tar.gz"
  ) {};
in {
  imports = [
    nur-no-pkgs.repos.LuisChDev.modules.nordvpn
  ];

  services.nordvpn.enable = true;

  nixpkgs.config.packageOverrides = pkgs: rec {
    nur = import (builtins.fetchTarball
      "https://github.com/nix-community/NUR/archive/master.tar.gz"
    ) {
      inherit pkgs;
    };
    nordvpn = nur.repos.LuisChDev.nordvpn;
  };

  networking.firewall = {
    checkReversePath = false;
    allowedTCPPorts = [ 443 ];
    allowedUDPPorts = [ 1194 ];
  };

  user.users.<username>.extraGroups = [ "nordvpn" ];


  # ...the rest of your configuration.nix
}
```

## Using flakes

### `flake.nix`
```
{
  inputs = {
    # ...your other inputs
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nur }: {
    nixosConfigurations.<yourSystem> = nixpkgs.lib.nixosSystem {
      # ...the rest of your config
      modules = let
        nur-modules = import nur rec {
          nurpkgs = nixpkgs.legacyPackages.x86_64-linux;
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        };
      in [
        # ...the rest of your modules
        nur.nixosModules.nur
        nur-modules.repos.LuisChDev.modules.nordvpn
      ];
    };
  };
}
```

### `configuration.nix`
```
{
  nixpkgs.config.packageOverrides = pkgs: {
    nordvpn = config.nur.repos.LuisChDev.nordvpn;
  };

  services.nordvpn.enable = true;

  users.users.<yourUser>.extraGroups = [
    # ...the rest of your groups
    "nordvpn"
  ];
}
```

## Login

Apparently an upstream issue, the browser login does not work directly, but
there's a workaround.

1. login on the browser
2. copy the link of the 'Continue' button
3. in the command line, run the command `nordvpn login --callback "PASTE URL
   HERE"` (quotes around the URL are required.)
