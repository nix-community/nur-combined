# NUR Package Lab

**My personal [NUR](https://github.com/nix-community/NUR) repository.**

[![Build Status](https://travis-ci.com/JoshuaFern/nur-package-lab.svg?branch=master)](https://travis-ci.com/JoshuaFern/nur-package-lab)
[![Cachix Cache](https://img.shields.io/badge/cachix-joshuafern-blue.svg)](https://joshuafern.cachix.org)

My goal is to submit as much as I can to [nixpkgs](https://github.com/NixOS/nixpkgs), but everything else goes here. For example:

* Packages that are only interesting for a small audience
* Pre-releases
* Old versions of packages that are no longer in Nixpkgs, but needed for legacy reason (i.e. old versions of GCC/LLVM)
* Automatic generated package sets (i.e. generate packages sets from PyPi or CPAN)
* Software with opinionated patches
* Experiments

I have enabled issues, pull requests, and even the wiki. Feel free to use them, but bugs specific to software itself should be sent upstream to the developer.

# Snapshots
The NUR Package Lab is developed against `nixpkgs-unstable` branch, which means it may depend on changes not yet released in stable NixOS. To avoid breaking users' configurations, snapshots are made in branches corresponding to NixOS releases (e.g. snapshot-20.03). These branches don't generally recieve updates, but if you need a specific backport feel free to open an issue.

The NUR uses the master branch by default, until they add multiple branch support you must use the snapshot branches manually.
