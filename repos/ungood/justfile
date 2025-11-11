# Build a specific package
build PACKAGE:
    nix build .#{{PACKAGE}}

# Build all CI packages
build-all:
    nix-build ci.nix -A cacheOutputs

# Check flake
check:
    nix flake check

# Update flake inputs
update:
    nix flake update

# List all available packages
list:
    nix flake show

# Run a package
run PACKAGE:
    nix run .#{{PACKAGE}}

# Clean build artifacts
clean:
    rm -f result result-*

# Format nix files
fmt:
    nix fmt
