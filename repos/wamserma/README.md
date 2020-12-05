# Nix da

**My personal [NUR](https://github.com/nix-community/NUR) repository**

[![Build Status](https://travis-ci.org/wamserma/nur-packages.svg?branch=master)](https://travis-ci.org/wamserma/nur-packages)
[![Cachix Cache](https://img.shields.io/badge/cachix-wamserma-blue.svg)](https://wamserma.cachix.org)
![Build and populate cache](https://github.com/wamserma/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

Want your own? I used [this template](https://github.com/nix-community/nur-packages-template).

## What's here?

I package up stuff here that is not interesting enough to clutter [nixpkgs](https://github.com/nixos/nixpkgs) with it. If you find somethig here that you want in [nixpkgs](https://github.com/nixos/nixpkgs), creat an issue and have people upvote.
Stuff here is mainly aiming for compatibility with the current stable release of NixOS, but many of this is also tested/used with Nix on Ubuntu or Debian.

Search: <https://nix-community.github.io/nur-search/repos/wamserma/>

### Admin tools

+ [bundlewrap](https://bundlewrap.org/) a lightweight, python-based alternative to Ansible

### Security Tools

+ [bandit](https://github.com/PyCQA/bandit) a static code analysis tool designed to find common security issues in Python code (just appifies the python package from Nixpkgs)
+ [encpipe](https://github.com/jedisct1/encpipe) a simple, pipeable encryption tool without runtime deps, with `encpipe-static` being a fully static binary (only 50K) that can run on any Linux system

### Libraries

+ [dietlibc](https://www.fefe.de/dietlibc/) a libc optimized for small size, useful for small statically linked binaries

### Games

+ [friidump](https://github.com/bradenmcd/friidump) a command-line tool to backup Gamecube and Wii game discs

### Misc

+ [Genius SF-600 Firmware](http://download.geniusnet.com/2012/Scanner/CP-SF600_Win8_V5.3.1.zip) Firmware blob for the Genius ColorPage SF-600 Scanner, to be used with SANE

+ Master PDF Editor 4.3.89, older version, last version that allowed for free text editing. Build with `NIXPKGS_ALLOW_UNFREE=1 nix-build -A masterpdfeditor4`. For current version, see [NIXPKGS](https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/misc/masterpdfeditor/default.nix).

## How to use?

Launch directly:
```
nix run -f "https://github.com/wamserma/nur-packages/archive/master.tar.gz" bundlewrap --command bw --version
```

One-off install (example):
```
nix-env -f "https://github.com/wamserma/nur-packages/archive/master.tar.gz" -iA bundlewrap
```

Persistent:
[see here](https://github.com/nix-community/NUR/blob/master/README.md)
