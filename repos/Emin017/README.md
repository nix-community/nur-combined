# nur-packages

**My personal [NUR](https://github.com/Emin017/nur-packages) repository**

<!-- Remove this if you don't use github actions -->
![Build and populate cache](https://github.com/Emin017/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

<!--
Uncomment this if you use travis:

[![Build Status](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages.svg?branch=master)](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages)

[![Cachix Cache](https://img.shields.io/badge/cachix-<YOUR_CACHIX_CACHE_NAME>-blue.svg)](https://<YOUR_CACHIX_CACHE_NAME>.cachix.org)
-->

**packages**:
* [gtkwave4](https://github.com/Emin017/nur-packages/blob/master/pkgs/gtkwave4/default.nix)
* [xfel](https://github.com/Emin017/nur-packages/blob/master/pkgs/xfel/default.nix)

## Home Manager modules

### `clash-verge-tailscale`

Provides Clash Verge Rev compatibility with Tailscale on Linux and macOS.
Without a tailnet, only the Fake-IP filter is added. Setting a tailnet enables
MagicDNS and tailnet routing with platform-specific rules: Linux binds its
Tailscale interface, while Darwin uses Network Extension-compatible DIRECT
rules and MagicDNS without an interface binding.

For standalone Home Manager or Home Manager embedded in NixOS:

```nix
imports = [ inputs.nur-packages.homeManagerModules.clash-verge-tailscale ];

programs.clash-verge.tailscale = {
  enable = true;
  # Optional on both Linux and Darwin:
  tailnet = "tail4121a.ts.net";
};
```

For nix-darwin, import both Home Manager and the Darwin adapter at the system
level, then enable the module for the desired user:

```nix
modules = [
  home-manager.darwinModules.home-manager
  inputs.nur-packages.darwinModules.clash-verge-tailscale
  {
    home-manager.users.example = {
      programs.clash-verge.tailscale = {
        enable = true;
        tailnet = "tail4121a.ts.net";
      };
    };
  }
];
```

This module manages the entire global `profiles/Script.js`. Migrate any
existing custom logic in that file before enabling the module. Consider
setting `home-manager.backupFileExtension = "backup";` in the consuming
NixOS or nix-darwin configuration so the first activation preserves the old
file.
