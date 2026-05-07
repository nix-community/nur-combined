# Testing Builds

Verify that packages build correctly and the resulting binaries work.

## Build Commands

```bash
# Build a package
nix build .#my-tool

# Build with unfree license allowed
NIXPKGS_ALLOW_UNFREE=1 nix build --impure .#my-tool

# Build for a specific system
nix build .#packages.x86_64-linux.my-tool

# Build and keep the result symlink
nix build .#my-tool --out-link result-my-tool
```

## Common Build Errors

### Hash Mismatch

```
error: hash mismatch in fixed-output derivation
```

**Fix:** Update the hash. Nix prints the expected and got hashes. Replace the hash in `default.nix`.

For multi-platform packages, you need to build on each platform or prefetch manually:

```bash
nix store prefetch-file --json "https://example.com/download/v1.0.0/tool-linux-x64.tar.gz"
```

### Missing Dependencies (Linux)

```
error: autoPatchelfHook: missing dependencies
```

**Fix:** Add missing libraries to `buildInputs`. Use `ldd` to find what's missing:

```bash
# After a failed build, check the log
nix log /nix/store/...my-tool.drv

# Or use steam-run to test
nix-shell -p steam-run
steam-run ./result/bin/my-tool
ldd ./result/bin/my-tool | grep "not found"
```

### Permission Denied

```
./my-tool: Permission denied
```

**Fix:** Ensure the binary is executable in `installPhase`:

```nix
installPhase = ''
  mkdir -p $out/bin
  cp my-tool $out/bin/my-tool
  chmod +x $out/bin/my-tool
'';
```

### Evaluation Error

```
error: attribute 'my-tool' missing
```

**Fix:** Make sure the package is registered in root `default.nix`:

```nix
my-tool = pkgs.callPackage ./pkgs/my-tool { };
```

## Testing the Result

### Basic Verification

```bash
# Check the binary exists and is executable
ls -la ./result/bin/
./result/bin/my-tool --version
./result/bin/my-tool --help
```

### Check Closure Size

```bash
nix path-info -S ./result
# Shows the total closure size - should be reasonable
```

### Check Dependencies

```bash
# What does the package depend on?
nix-store -qR ./result

# What's the runtime closure?
nix-store -q --references ./result
```

### Test on Multiple Platforms

If you have access to different systems:

```bash
# Linux x86_64
nix build .#packages.x86_64-linux.my-tool

# Linux aarch64 (cross-compilation or remote builder)
nix build .#packages.aarch64-linux.my-tool

# macOS x86_64
nix build .#packages.x86_64-darwin.my-tool

# macOS aarch64 (Apple Silicon)
nix build .#packages.aarch64-darwin.my-tool
```

### Quick Cross-Platform Verification (No Remote Builder)

If you can only build locally, at minimum verify the nix expression evaluates for all platforms:

```bash
# Check evaluation for all platforms
nix eval .#my-tool.meta.platforms

# Or just verify the derivation can be instantiated
nix-instantiate --eval -E '(import ./. {}).my-tool.meta.platforms'
```

### FOD (Fixed-Output Derivation) Hash Verification

For `fetchurl` hashes, always verify by actually building. Do NOT just accept hashes from upstream checksums pages—they may use different hashing algorithms or formats.

```bash
# Build to verify the hash is correct
nix build .#my-tool

# If hash is wrong, Nix will tell you the correct one
```

## Testing npm Packages

```bash
# Build the npm package
nix build .#my-npm-tool

# Verify it works
./result/bin/my-npm-tool --version

# Check that node modules are properly included
ls ./result/lib/node_modules/
```

## Testing AppImages

```bash
# Build the AppImage wrapper
nix build .#my-app

# Run it (AppImages need FHS compatibility)
./result/bin/my-app

# If it fails, check the wrapper
cat ./result/bin/my-app
```

## CI Testing

The repo has CI in `.github/workflows/build.yml`. After pushing, verify:

1. The package evaluates correctly (nix eval)
2. The package builds on all target nixpkgs channels
3. The package appears in the NUR registry

Check CI status at:
```bash
gh run list --workflow=build.yml
gh run view <run-id>
```

## Pre-Flight Checklist

Before considering a package complete, verify:

- [ ] `nix build .#<name>` succeeds without errors
- [ ] `./result/bin/<name> --version` or `--help` works
- [ ] No unnecessary dependencies in the closure
- [ ] License is correctly set
- [ ] Description is accurate
- [ ] Package is registered in root `default.nix`
- [ ] All platform hashes are correct (not placeholder)
- [ ] CI passes (if configured)