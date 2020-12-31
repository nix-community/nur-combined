# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

[![Build Status](https://travis-ci.org/moaxcp/nur.svg?branch=master)](https://travis-ci.org/moaxcp/nur)
[![Cachix Cache](https://img.shields.io/badge/cachix-moaxcp-blue.svg)](https://moaxcp.cachix.org)

A nix repository containing mostly extra versions of java tools.

# Notes

## Gradle

Gradle doesn't seem to have pname which I believe is a required convention in nixpkgs

gradle doesn't have a darwin build which I believe is osx. I may not need to but there is a platform native jar for it

native-platform-osx-amd64-0.21.jar

## adoptopenjdk-bin

https://ci.adoptopenjdk.net produces artifacts with metadata.
https://ci.adoptopenjdk.net/job/build-scripts/job/jobs/
https://api.adoptopenjdk.net/

## install checks

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

Right now this repository is mostly geared towards java development. It contains versions of packages that may be 
removed at any time in nixpkgs.

# Conventions

There are no general attributes for the latest package. You have to select the specific version to install.

installChecks should be added to every package

# helpful tools for adding packages

## pkgs/adoptopenjdk-bin/generate-sources.py

updates sources.json with latest versions from adoptopenjdk. Update variables in top of file for versions to add. 
nightly builds can also be added.

## nix-prefetch-url

adds a download to the nix store and prints the hash.