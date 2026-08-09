# Tests

This directory contains tests for the update scripts.

## Running tests

### Simple bash tests (recommended for CI)

```bash
./tests/run-tests.sh
```

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
6. **optiscaler-client deps** - `deps.json` is valid JSON (if exists)

## Adding tests for new packages

Edit `tests/run-tests.sh` and add the package name to the `PACKAGES` array:

```bash
PACKAGES=(
    "cybergrub2077"
    "optiscaler-client"
    "rimsort-appimage"
    "scopebuddy"
    "vs-launcher"
    "wowup-cf"
    "new-package"  # Add here
)
```

For BATS tests, add new test cases in `tests/update-scripts.bats`.
