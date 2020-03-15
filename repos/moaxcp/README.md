# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

[![Build Status](https://travis-ci.org/moaxcp/nur.svg?branch=master)](https://travis-ci.com/moaxcp/nur)
[![Cachix Cache](https://img.shields.io/badge/cachix-moaxcp-blue.svg)](https://moaxcp.cachix.org)


# Notes

## Gradle

Gradle doesn't seem to have pname which I believe is a required convention in nixpkgs

gradle doesn't have a darwin build which I believe is osx. I may not need to but there is a platform native jar for it

native-platform-osx-amd64-0.21.jar

## adoptopenjdk-bin

How to access stdenv in ./default.nix? adoptopenjdk-bin uses and adding support for many more versions will require it.

https://ci.adoptopenjdk.net produces artifacts with metadata.
https://ci.adoptopenjdk.net/job/build-scripts/job/jobs/
https://api.adoptopenjdk.net/

## micronaut

Need to add other versions and standard way to support multiple versions.

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

Versions are always included in the attribute.

Attribute format

```
${pname}-${underscore_version}
```

`underscore_version` is the version with special characters replaced by underscores.