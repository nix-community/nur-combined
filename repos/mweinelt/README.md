# nur-packages

![Build Status](https://github.com/mweinelt/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-mweinelt-blue.svg)](https://mweinelt.cachix.org)


**My personal [NUR](https://github.com/nix-community/NUR) repository**

This nur repository provides a binary cache through the free tier of cachix.org. To use it, add the following line to your nix.conf:

```
substituters = https://mweinelt.cachix.org
trusted-public-keys = mweinelt.cachix.org-1:J9OCu2VAPJ2IHzpOfoJt16Fm5xl9q8VOHqcqCGSNKsM=
```
