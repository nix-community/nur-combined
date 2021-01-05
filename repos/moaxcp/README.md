# nur

**A [Nix User Repository](https://github.com/nix-community/NUR) for java developers**

[![Build Status](https://travis-ci.org/moaxcp/nur.svg?branch=master)](https://travis-ci.org/moaxcp/nur)
[![Cachix Cache](https://img.shields.io/badge/cachix-moaxcp-blue.svg)](https://moaxcp.cachix.org)

Supported packages:

* adoptopenjdk-bin
* adoptopenjdk-jre-bin
* gradle
* groovy
* micronaut-cli
* spring-boot-cli

# Purpose

* To provide multiple versions of java packages to developers
* Support java applications and switch which jdk/jre is used
* Provided latest packages available and other major versions
* Support overlays with nixpkgs

# Users

Add the channel

```
nix-channel --add http://github.com/nix-community/NUR/archive/master.tar.gz nur
```

Add the overlay

```
nixpkgs.overlays = [                                                        
  nur.repos.moaxcp.overlays.use-moaxcp-nur-packages
];
```

declare the package to install.

```
environment.systemPackages = with pkgs; [
  adoptopenjdk-hotspot-bin-15
  gradle-6_7_1
  groovy-4_0_0-alpha-2
  micronaut-cli-2_2_2
];
```

There are "use" overlays which can switch the jdk used for the tools. For 
example to switch the tools to adoptopenjdk-15:

```
nixpkgs.overlays = [                                                        
  nur.repos.moaxcp.overlays.use-moaxcp-nur-packages
  nur.repos.moaxcp.overlays.use-adoptopenjdk15
];
```

There is also an overlay that will update everything in nixpkgs to the latest
version.

```
nixpkgs.overlays = [                                                        
  nur.repos.moaxcp.overlays.use-moaxcp-nur-packages
  nur.repos.moaxcp.overlays.use-latest
];
```

# Conventions

`overlays` directory contains overlays for different combinations 
adoptopenjdk-bin. For instance to use adoptopenjdk-bin-11 with all of the
packages within this repo use the `use-adoptopenjdk11` overlay.

There is a `use-latest` overlay which will upgrade all the packages in
 nixpkgs to the latest versions in this repo.
 
The overlays do not change the `jdk` package since that can cause a rebuild of 
libreoffice and VirtualBox which takes a long time.

## Notes

### Gradle

Gradle doesn't seem to have pname in unstable which I believe is a required 
convention in nixpkgs

gradle doesn't have a darwin build. I may not need to but there is a platform 
native jar for it

native-platform-osx-amd64-0.21.jar

### adoptopenjdk-bin

https://ci.adoptopenjdk.net produces artifacts with metadata.
https://ci.adoptopenjdk.net/job/build-scripts/job/jobs/
https://api.adoptopenjdk.net/

### install checks on all packages

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

## helpful tools for adding packages

### pkgs/adoptopenjdk-bin/generate-sources.py

updates sources.json with latest versions from adoptopenjdk. Update variables 
in top of file for versions to add. nightly builds can also be added.

### nix-prefetch-url

adds a download to the nix store and prints the hash.
