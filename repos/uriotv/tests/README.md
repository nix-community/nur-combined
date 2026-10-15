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
