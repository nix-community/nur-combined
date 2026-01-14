# List available commands
default:
    @just --list

# Format all Nix files
fmt:
    @echo "Formatting Nix files with treefmt..."
    treefmt --excludes .direnv
    @echo "✓ Done"

# Run linters
lint:
    @echo "Running Nix linters..."
    @echo ""
    @echo "==> Running statix (checking for anti-patterns)..."
    @statix check . --ignore .direnv pkgs/zlint/deps.nix && echo "✓ statix: no issues found" || echo "✗ statix found issues (run 'statix fix' to auto-fix)"
    @echo ""
    @echo "==> Running deadnix (finding unused code)..."
    @deadnix --fail . --exclude .direnv pkgs/zlint/deps.nix && echo "✓ deadnix: no unused code found" || echo "✗ deadnix found unused code"
    @echo ""
    @echo "Done!"

# Check formatting and run linters
check:
    @echo "Running all checks..."
    @echo ""
    @echo "==> Checking formatting..."
    @treefmt --excludes .direnv --fail-on-change . && echo "✓ All files are formatted correctly" || echo "✗ Some files need formatting (run 'just fmt' to fix)"
    @echo ""
    @just lint

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

