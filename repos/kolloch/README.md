# Peter's nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

[![Build Status](https://travis-ci.com/kolloch/nur-packages.svg?branch=master)](https://travis-ci.com/kolloch/nur-packages)
[![Cachix Cache](https://img.shields.io/badge/cachix-eigenvalue-blue.svg)](https://eigenvalue.cachix.org)

## rerunFixedDerivationOnChange

Creates a fixed output derivation that reruns if any of its inputs change.

Type: `rerunFixedDerivationOnChange -> derivation -> derivation`

Example:

```nix
let myFixedOutputDerivation = pkgs.stdenv.mkDerivation {
  # ...
  outputHash = "sha256:...";
  outputHashMode = "recursive";
};
in
nur.repos.kolloch.lib.rerunFixedDerivationOnChange myFixedOutputDerivation
```

Usually, fixed output derivations are only rerun if their name or hash
changes (i.e. when their output path changes). This makes the derivation
definition irrelevant if the output is in the cache.

With this helper, you can make sure that the commands that are specified
where at least ran once -- with the exact versions of the buildInputs that
you specified. It does so by putting a hash of all the inputs into the
name.

Caveat: It uses "import from derivation" under the hood.

### Implementation

Getting the hash is easy, in principle, because nix already does that work
for us when creating the output paths for non-fixed output derivations.
Therefore, if we create a non-fixed output derivation with the same inputs,
the hash in the output path should change with every change in inputs.
Unfortunately, we cannot use parts of the output path in the name of our
derivation directly.

Nix prevents this because supposedly it is not what you want. I don't think
that it is actually problematic in principle.

To work around this, I use an import-from-derivation call to get the output
path. The disadvantage is that all the dependencies of your fixed output
derivation will be build in the eval phase.

## Nix unit tests with nice diffing output

`nur.repos.kolloch.lib.runTest` exposes `nix-test-runner` runTest.

Docs are at the [nix-test-runner
repository](https://github.com/stoeffel/nix-test-runner).
