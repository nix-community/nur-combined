# Nix da

**My personal [NUR](https://github.com/nix-community/NUR) repository**

[![Build Status](https://travis-ci.org/wamserma/nur-packages.svg?branch=master)](https://travis-ci.org/wamserma/nur-packages)
[![Cachix Cache](https://img.shields.io/badge/cachix-wamserma-blue.svg)](https://wamserma.cachix.org)

Want your own? I used [this template](https://github.com/nix-community/nur-packages-template).

## What's here?

I package up stuff here that is not interesting enough to clutter [nixpkgs](https://github.com/nixos/nixpkgs) with it. If you find somethig here that you want in [nixpkgs](https://github.com/nixos/nixpkgs), creat an issue and have people upvote.
Stuff here is mainly aiming for compatibility with the current stable release of NixOS, but many of this is also tested/used with Nix on Ubuntu or Debian.

Search: <https://nix-community.github.io/nur-search/repos/wamserma/>

### Admin tools

+ [bundlewrap](https://bundlewrap.org/) a lightweight, python-based alternative to Ansible

### Security Tools

+ [bandit](https://github.com/PyCQA/bandit) a static code analysis tool designed to find common security issues in Python code
(without self tests due to the test dependencies)

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
