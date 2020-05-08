# Peter's nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

[![Build Status](https://travis-ci.com/kolloch/nur-packages.svg?branch=master)](https://travis-ci.com/kolloch/nur-packages)
[![Cachix Cache](https://img.shields.io/badge/cachix-eigenvalue-blue.svg)](https://eigenvalue.cachix.org)

## rerunOnChange for Fixed Output Derivations

See inline docs in [rerun-fixed.nix](./lib/rerun-fixed.nix).

## Nix unit tests with nice diffing output

`nur.repos.kolloch.lib.runTest` exposes `nix-test-runner` runTest.

Docs are at the [nix-test-runner
repository](https://github.com/stoeffel/nix-test-runner).
