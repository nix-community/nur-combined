# Nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

![Build Status](https://github.com/ijohanne/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)
[![Attic Cache](https://img.shields.io/badge/attic-ijohanne-blue.svg)](https://ijohanne.nix-cache.unixpimps.net)

It provides a pre-compiled binary cache for NixOS unstable.

If you consume this repository as a flake, the cache is advertised automatically via `nixConfig`.

To configure Nix manually, add the following to your `nix.conf`:

```
substituters = https://nix-cache.unixpimps.net/ijohanne
trusted-public-keys = ijohanne:55EJTBFbq5pCYx2tf+aR8pmVPvCmP7QlafHH90/kikw=
```
