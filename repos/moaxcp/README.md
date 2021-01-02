# nur

**A [Nix User Repository](https://github.com/nix-community/NUR) for java developers**

[![Build Status](https://travis-ci.org/moaxcp/nur.svg?branch=master)](https://travis-ci.org/moaxcp/nur)
[![Cachix Cache](https://img.shields.io/badge/cachix-moaxcp-blue.svg)](https://moaxcp.cachix.org)

# Notes

## Gradle

Gradle doesn't seem to have pname in unstable which I believe is a required convention in nixpkgs

gradle doesn't have a darwin build. I may not need to but there is a platform native jar for it

native-platform-osx-amd64-0.21.jar

## adoptopenjdk-bin

https://ci.adoptopenjdk.net produces artifacts with metadata.
https://ci.adoptopenjdk.net/job/build-scripts/job/jobs/
https://api.adoptopenjdk.net/

## install checks on all packages

These should be added. jmeter is a good example.

```
  installCheckPhase = ''
    $out/bin/jmeter --version 2>&1 | grep -q "${version}"
    $out/bin/jmeter-heapdump.sh > /dev/null
    $out/bin/jmeter-shutdown.sh > /dev/null
    $out/bin/jmeter-stoptest.sh > /dev/null
    timeout --kill=1s 1s $out/bin/jmeter-mirror-server.sh || test "$?" = "124"
  '';
```

# Purpose

* To provide packages to java developers
* Manage multiple versions of java applications
* Provided latest packages available
* Overlay with nixpkgs so it uses latest versions

# Conventions

installChecks should be added to every package

# helpful tools for adding packages

## pkgs/adoptopenjdk-bin/generate-sources.py

updates sources.json with latest versions from adoptopenjdk. Update variables in top of file for versions to add. 
nightly builds can also be added.

## nix-prefetch-url

adds a download to the nix store and prints the hash.
