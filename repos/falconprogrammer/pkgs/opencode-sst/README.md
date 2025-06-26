# OpenCode NixOS Compatibility Fix

This package provides a NixOS-compatible version of OpenCode that addresses runtime binary compatibility issues.

## The Problem

OpenCode downloads and executes TUI binaries at runtime to `~/.cache/opencode/`. These binaries are compiled for generic Linux distributions and use the standard dynamic linker path `/lib64/ld-linux-x86-64.so.2`, which doesn't exist on NixOS.

**Why this happens:**
- OpenCode is distributed as a precompiled binary that downloads additional components
- Downloaded binaries expect standard FHS (Filesystem Hierarchy Standard) paths
- NixOS uses the Nix store (`/nix/store/...`) for all system components
- The dynamic linker location differs: `/nix/store/*/lib/ld-linux-x86-64.so.2` vs `/lib64/ld-linux-x86-64.so.2`

**Error you'll see:**
```
Could not start dynamically linked executable: /home/user/.cache/opencode/tui/tui-xxxxx.
NixOS cannot run dynamically linked executables intended for generic linux environments
```

## The Solution

This package provides multiple approaches to fix the dynamic linking issue:

### 1. Use OpenCode (Recommended)
```bash
nix-shell -p (import ./default.nix {})
opencode  # Automatically patches cache before each run
```

### 2. Manual Cache Patching
```bash
# Run opencode first (it will fail with the error above)
opencode

# Patch the problematic binaries manually
./patch-opencode-cache.sh

# Now opencode should work
opencode
```

### 3. Using the Built Package
```bash
nix-build -A opencode-sst
./result/bin/opencode  # Main binary with automatic patching
# Or manually: ./result/share/opencode/patch-opencode-cache.sh
```

## Technical Details

The fix uses `patchelf` to modify the interpreter (dynamic linker) field in ELF binaries:
- **Before:** `/lib64/ld-linux-x86-64.so.2` (doesn't exist on NixOS)
- **After:** `/nix/store/*/lib/ld-linux-x86-64.so.2` (NixOS dynamic linker)

The wrapper script automatically:
1. Scans `~/.cache/opencode/` for executable files
2. Identifies dynamically linked binaries
3. Checks if they use NixOS-compatible dynamic linker paths
4. Patches incompatible binaries with `patchelf --set-interpreter`
5. Runs the original opencode binary

This patching happens automatically every time you run `opencode`, ensuring compatibility without manual intervention.

## Additional Benefits

- **Node.js Integration:** Provides NixOS-compatible Node.js in PATH
- **Environment Variables:** Sets `OPENCODE_NODEJS_PATH` to prevent Node.js downloading
- **Library Paths:** Includes proper `LD_LIBRARY_PATH` for runtime dependencies