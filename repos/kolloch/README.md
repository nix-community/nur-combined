# Peter's nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

[![Build Status](https://travis-ci.com/kolloch/nur-packages.svg?branch=master)](https://travis-ci.com/kolloch/nur-packages)
[![Cachix Cache](https://img.shields.io/badge/cachix-eigenvalue-blue.svg)](https://eigenvalue.cachix.org)

## Jitsi Module

I copied packages and modules from [this
PR](https://github.com/NixOS/nixpkgs/pull/82920) with the
`rip-jitsi-meet-modules.sh` in this repo. At the time of writing this, it
depends on some changes to the `prosody` module in `nixpkgs-unstable`.

### Import module

With [niv](https://github.com/nmattia/niv):

```bash
niv add -n kollochNurPackages kolloch-nur-packages
```

```nix
{ config, pkgs, lib, ... }:

{
  imports =
    let sources = import ../nix/sources.nix;
        kollochNurPackages = import sources.kollochNurPackages {};
        kollochModules = kollochNurPackages.modules;
    in
    [
      # ...
      kollochModules.jitsi
    ];

  # ...
}
```

Or look at the [NUR
documentation](https://github.com/nix-community/NUR/blob/master/README.md).

### Sample config

```nix
{ config, pkgs, lib, ... }:

{
  # ...

  services.jitsi-videobridge.openFirewall = true;

  services.jitsi-meet = {
    hostName = "meet.yourdomain.toplevel";
    enable = true;
    nginx.enable = true;
    jicofo.enable = true;
    videobridge.enable = true;
    prosody.enable = true;

    config = {
      # Allow access from mobile without app.
      disableDeepLinking = true;
    };

    interfaceConfig = {
      APP_NAME = "Yor App Name";
      SHOW_JITSI_WATERMARK = false;
      SHOW_WATERMARK_FOR_GUESTS = false;
      MOBILE_APP_PROMO = false;
      DEFAULT_REMOTE_DISPLAY_NAME = "Fellow Mushroom";
    };
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    virtualHosts = {
      "${config.services.jitsi-meet.hostName}" = {
        # permanent redirect from http to https
        forceSSL = config.security.acme.acceptTerms;
        # Use automatic let's encrypt certificate
        enableACME = config.security.acme.acceptTerms;
      };
    };
  };
}
```

## rerunOnChange for Fixed Output Derivations

See inline docs in [rerun-fixed.nix](./lib/rerun-fixed.nix).

## Nix unit tests with nice diffing output

`nur.repos.kolloch.lib.runTest` exposes `nix-test-runner` runTest.

Docs are at the [nix-test-runner
repository](https://github.com/stoeffel/nix-test-runner).
