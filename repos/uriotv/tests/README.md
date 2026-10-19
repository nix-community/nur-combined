# Tests

This directory contains tests for the update scripts.

## Running tests

### Simple bash tests (recommended for CI)

```bash
./tests/run-tests.sh
```

The bash runner also executes `tests/update-workflow.py` (Python 3 standard
library only). These offline regression tests use temporary package fixtures;
they do not contact upstream, invoke Nix, or modify repository packages. They
verify that failed updates restore the package directory, successful updates
before and after a failure are retained, and summaries report failures without
blocking PR creation. Invalid package selections remain hard errors.

### CachyOS kernel

The bash runner also executes `kernel-workflow.py`: offline tests for atomic
source/compiler snapshot updates, failure rollback, complete-output publication
and the required gate's success/failure/cancelled/skipped handling.

The separate kernel CI evaluates both the isolated module behavior and a real
NixOS configuration (including BORE/v3/no-LTO settings and identical kernel drv):

```console
nix eval --impure --json --expr 'import ./tests/cachyos-module.nix {}'
nix eval --impure --json --file tests/cachyos-integration.nix
```

The bash runner additionally executes `local-kernel-build.py` with stubbed Nix,
Cachix and network commands. It checks build-only mode, token-file publication,
all-output selection, credential isolation, invalid arguments and remote
verification failures without compiling anything or making network calls.

These evaluations do not compile or boot the kernel. `kernel.yml` performs the
full compilation, all-output publication and remote narinfo verification on
main. PRs compile without write credentials. The first full CI build is also a
runner-capacity measurement; do not treat local evaluation as build success.

### BATS tests (more comprehensive)

```bash
# Install bats first
sudo apt-get install bats

# Run tests
bats tests/update-scripts.bats
```

## What is tested

1. **Package structure** - Each package has a `default.nix` file
2. **Update script existence** - Each package has an executable `update.sh`
3. **Script structure** - Scripts have proper shebang and `set -euo pipefail`
4. **nix-update usage** - Scripts use `nix-update` for updates
5. **Flake support** - Scripts use `--flake` flag for flake-based packages

## Adding tests for new packages

Edit `tests/run-tests.sh` and add the package name to the `PACKAGES` array:

```bash
PACKAGES=(
    "cybergrub2077"
    "rimsort-appimage"
    "scopebuddy"
    "wowup-cf"
    "new-package"  # Add here
)
```

For BATS tests, add new test cases in `tests/update-scripts.bats`.
