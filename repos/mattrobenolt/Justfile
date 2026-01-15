# List available commands
default:
    @just --list

# Format all Nix files (runs deadnix, statix, and nixfmt)
fmt:
    treefmt

# Check formatting (verifies deadnix, statix, and nixfmt)
check:
    @echo "Checking formatting..."
    @treefmt --fail-on-change && echo "✓ All files are properly formatted" || echo "✗ Some files need formatting (run 'just fmt' to fix)"

# Update Go versions and hashes
update-go:
    @./pkgs/go/update.py

# Update zlint stable and unstable packages
update-zlint:
    @./pkgs/zlint/update.py

# Update inbox package
update-inbox:
    @./pkgs/inbox/update.py

# Update zigdoc package
update-zigdoc:
    @./pkgs/zigdoc/update.py

# Update all packages
update-all:
    @just update-go
    @just update-zlint
    @just update-inbox
    @just update-zigdoc

