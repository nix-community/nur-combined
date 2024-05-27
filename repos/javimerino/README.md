# My personal [NUR](https://github.com/nix-community/NUR) repository

![Build and populate cache](https://github.com/JaviMerino/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)
![Lints](https://github.com/JaviMerino/nur-packages/workflows/Lints/badge.svg)
![Check
flake](https://github.com/JaviMerino/nur-packages/workflows/Check%20flake/badge.svg)

<!--
Uncomment this if you set up cachix:
[![Cachix Cache](https://img.shields.io/badge/cachix-<YOUR_CACHIX_CACHE_NAME>-blue.svg)](https://<YOUR_CACHIX_CACHE_NAME>.cachix.org)
-->

## Packages

Check [NUR search](https://nur.nix-community.org/repos/javimerino/)
for the available packages.

## Modules

* ollama systemd service as a home-manager module.

Use like you would any other home-manager module from NUR.  Set
nur-no-pkgs as [the NUR README
describes](https://github.com/nix-community/NUR?tab=readme-ov-file#using-modules-overlays-or-library-functions-in-nixos),
then add the module to your home-manager imports:

``` nix
  imports = [
    nur-no-pkgs.repos.javimerino.modules.ollama

    [...]
  ];
```

And configure it:

``` nix
{pkgs, ... }:
{
  home.packages = [ pkgs.ollama ];

  services.ollama.enable = true;
}
```

After activating it with `home-manager switch`, don't forget to start
the service: `systemctl --user start ollama`.  Afterwards, any
`ollama` command will find the server running (eg. `ollama run
llama3`).
