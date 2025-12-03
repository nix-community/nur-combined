# sbt-derivation

A [Nix](https://nixos.org/) library for building
[sbt](https://www.scala-sbt.org/)-based, [Scala](https://www.scala-lang.org/)
projects with Nix.

[![Tests](https://github.com/zaninime/sbt-derivation/actions/workflows/tests.yml/badge.svg)](https://github.com/zaninime/sbt-derivation/actions/workflows/tests.yml)
[![GitHub license](https://badgen.net/github/license/zaninime/sbt-derivation)](https://github.com/zaninime/sbt-derivation/blob/master/LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

---

*Note: you are browsing the version 2 of this project. If you've been using
this library already in your projects, please follow the [migration guide
below](#migration-guide).*

## Features

- Sane defaults: start by only specifying the options required by Nix (4 in total)
- More advanced options for specific use-cases
- Compatible with sbt > 1.5.1 up until latest
- Tested by GitHub actions against a matrix of sbt versions and Scala 2.12, 2.13, 3.1
- Follows similar conventions as used in Nixpkgs
- Reduced footprint: depends on `sbt`, `find`, `sed` and a couple of utils to make the JARs reproducible
  - *Depending on the archival strategy, the number of tools might increase, e.g. `tar` is necessary for making archives*

## How it works

The mechanism used by sbt-derivation is the same as the one used in other
language ecosystems in Nixpkgs, e.g. Go and Rust.
Internally, two derivations are created: one for the dependencies and one for the actual build.

The dependencies derivation is a *fixed-output derivation*, it has a hash that needs to be changed each time the dependencies are updated or changed in any way. It's also far from trivial to calculate this hash programmatically, strictly from the project files. The proposed solution is *trust on first use* (aka let a build fail the first time and use the hash that Nix prints).

The actual build derivation copies the dependencies in the workspace before running the build step. The provided `sbt` is already configured to point to those.

## Installation

There are three ways of installing this library in your project.

---

<details>
  <summary><b>If your project uses <a href="https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake.html">Flakes</a></b></summary>

  Simply add an input to your Flake pointing to this repository.
  
  ```nix
  {
    description = "My Scala project";

    # you probably have this one already
    inputs.nixpkgs.url = "github:NixOS/nixpkgs";

    # add this line
    inputs.sbt.url = "github:zaninime/sbt-derivation";
    # recommended for first style of usage documented below, but not necessary
    inputs.sbt.inputs.nixpkgs.follows = "nixpkgs";

    outputs = {
      self,
      nixpkgs,
      sbt,
    }: {
      # first style of usage
      packages.x86_64-linux.my-first-scala-package = sbt.mkSbtDerivation.x86_64-linux {
        pname = "my-scala-package";
        # ...see below for all parameters
      };

      # second style of usage
      packages.x86_64-linux.my-second-scala-package = sbt.lib.mkSbtDerivation {
        # pass your pkgs here
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

        # ...and the rest of the arguments
        pname = "my-scala-package";
      };
    };
  }
  ```
</details>

---

<details>
  <summary><b>If your project uses <a href="https://github.com/nmattia/niv">Niv</a> (or equivalent)</b></summary>

  Add the dependency by using:

  ```sh
  $ niv add zaninime/sbt-derivation
  ```

  Import then the overlay and pass it to your copy of nixpkgs.

  ```nix
  let
    sources = import ./nix/sources.nix;

    sbt-derivation = import "${sources.sbt-derivation}/overlay.nix";
    pkgs = import sources.nixpkgs { overlays = [sbt-derivation]; };
  in
    pkgs.mkSbtDerivation {
      pname = "my-scala-package";
      # ...see below for all parameters
    }
  ```
</details>

---

<details>
  <summary><b>Alternative generic method</b></summary>

  Get a copy of this repository, e.g. via the builtin, and load the overlay.

  ```nix
  let
    repository = builtins.fetchTarball {
      url = "https://github.com/zaninime/sbt-derivation/archive/master.tar.gz";
    };

    sbt-derivation = import "${repository}/overlay.nix";
  in import nixpkgs { overlays = [sbt-derivation]; }
  ```

  Pinning is recommended for reproducibility.
</details>

---

## Options

```nix
mkSbtDerivation {
  ### REQUIRED OPTIONS

  # the name of the derivation
  pname = "my-package";

  # the version of the derivation
  version = "1.0.0";

  # the path to the sources
  src = fetchFromGitHub {
    # ...
  };
  
  # The SHA256 of the dependencies derivation
  # Set it to empty (or 52 zeros if it doesn't work) the first time.
  # Nix will complain that is the wrong hash, copy-paste the one computed by Nix here.
  #
  # Note: if you update nixpkgs, sbt-derivation or the dependencies in your project, the hash will change!
  #  repeat the procedure above every time.
  depsSha256 = "";

  # build your software with sbt, consider running unit tests too!
  buildPhase = ''
    sbt compile
  '';

  # install your software in $out, depending on your needs
  installPhase = ''
    cp target/my-app.jar $out
  '';


  ### OPTIONAL

  # packages you need during the build
  # note: no need to add sbt, it is always present
  nativeBuildInputs = [ pkgs.hello ];

  # any other attribute valid for `stdenv.mkDerivation`
  # e.g. environment variables passed to the builder
  MY_ENV = "1";
  # e.g. tests, etc.
  passthru.tests = testsPackage;
  # e.g. patches
  patches = [./my-patch.patch];


  ### ADVANCED

  # (optional) Command to run to let sbt fetch all the required dependencies for the build.
  #
  # defaults to 'sbt compile'
  depsWarmupCommand = ''
    sbt myCommand
  '';

  # (optional) Strategy to use to package and unpackage the dependencies
  # - copy: stored as a regular directory, copy before build
  # - link: stored as a regular directory, use GNU stow to link files in the build dir
  # - tar: tar archive, not compressed
  # - tar+zstd: tar archive, compressed with zstd
  #
  # Note: zstd changes formats often, so expect more frequent hash changes when you update nixpkgs.
  #
  # defaults to 'tar+zstd'
  depsArchivalStrategy = "copy";

  # (optional) Whether to further reduce the side of the dependencies derivation by removing duplicate files.
  # Disable it in case of unexpected behaviour.
  #
  # default to true
  depsOptimize = false;

  # (optional) A function to override the dependencies derivation attributes
  #
  # defaults to a function that doesn't produce overrides
  overrideDepsAttrs = final: prev: {
    preBuild = ''
      echo something > file.txt
    '';
  };
}
```

## <a name="migration-guide"></a>Migrating from v1

If you're not ready to migrate, the previous version is kept in a branch called `release/v1.x`. You can track that instead of master, while you plan your migration.

### Removed options
- `versionInDepsName`: this is now always `false`.
- `depsBuildPhase`: override the `buildPhase` of the dependencies instead.
- `depsInstallPhase`: same as above.

### Changed behaviour
- `postConfigure` will now run after extracting the dependencies (was running before). The whole configure phase is used to extract the dependencies.
- The dependencies are no longer stored in a `.nix` directory, but rather in a temporary global directory mirroring the structure used by sbt in `--no-share` mode.
- `overrideDepsAttrs` now takes two parameters, `final` and `prev`, instead of just `prev`.

### New options
The options `depsArchivalStrategy`, `depsOptimize` are new. See above for the usage.

## Common problems and gotchas

1. Your build will fail if you forget to remove or ignore the `target` folders in
the root directory, as well as in the `project` directories. They contain some
files that reference paths outside the sandbox. Remove the directories and try
the build again.

2. At the moment, when building the dependencies, a full `sbt compile` is being
run, as it's the only command that safely download everything needed for a
build. For bigger projects this is slow.
    - Two workarounds ([1](https://github.com/zaninime/sbt-derivation/issues/8#issuecomment-1128022172), [2](https://github.com/zaninime/sbt-derivation/issues/8#issuecomment-1200327608)) are mentioned in GitHub issues
    - For some projects in Scala 3, `sbt 'managedClasspath; compilers'` produce the same output as `sbt compile`
    - Feel free to experiment with different `depsWarmupCommand`s and please report your findings!
