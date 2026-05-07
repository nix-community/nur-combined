---
title: Finding Missing Library Dependencies
impact: CRITICAL
impactDescription: Binaries fail to run without correct library dependencies
tags: libraries, ldd, dependencies, debugging, missing-libs
---

## Finding Missing Library Dependencies

When binaries fail to run with "library not found" errors, you need to identify which Nix packages provide those libraries.

## Method 1: Run and Check Errors

```bash
# Build the package first
nix-build

# Try to run the binary
result/bin/myapp

# You'll see errors like:
# error while loading shared libraries: libgtk-3.so.0: cannot open shared object file
```

## Method 2: Use ldd

```bash
# Check all library dependencies
ldd result/bin/myapp | grep "not found"

# Output shows missing libraries:
# libgtk-3.so.0 => not found
# libglib-2.0.so.0 => not found
# libpulse.so.0 => not found
```

## Common Library Mappings

| Missing Library | Nix Package | Notes |
|-----------------|-------------|-------|
| `libgtk-3.so.0` | `gtk3` | GTK+ 3 toolkit |
| `libglib-2.0.so.0` | `glib` | GLib utility library |
| `libgio-2.0.so.0` | `glib` | Part of glib |
| `libgobject-2.0.so.0` | `glib` | Part of glib |
| `libpulse.so.0` | `libpulseaudio` | PulseAudio |
| `libasound.so.2` | `alsa-lib` | ALSA sound |
| `libGL.so.1` | `mesa` or `libglvnd` | OpenGL |
| `libEGL.so.1` | `mesa` or `libglvnd` | EGL |
| `libxkbcommon.so.0` | `libxkbcommon` | Keyboard handling |
| `libX11.so.6` | `xorg.libX11` | X11 library |
| `libXcomposite.so.1` | `xorg.libXcomposite` | X11 composite extension |
| `libXdamage.so.1` | `xorg.libXdamage` | X11 damage extension |
| `libXext.so.6` | `xorg.libXext` | X11 misc extension |
| `libXfixes.so.3` | `xorg.libXfixes` | X11 fixes extension |
| `libXrandr.so.2` | `xorg.libXrandr` | X11 RandR extension |
| `libcairo.so.2` | `cairo` | Cairo graphics |
| `libpango-1.0.so.0` | `pango` | Text layout |
| `libgdk_pixbuf-2.0.so.0` | `gdk-pixbuf` | Image loading |
| `libdrm.so.2` | `libdrm` | Direct rendering |
| `libdbus-1.so.3` | `dbus` | D-Bus IPC |
| `libnss3.so` | `nss` | Network security |
| `libnspr4.so` | `nspr` | Netscape portable runtime |
| `libcups.so.2` | `cups` | Printing |
| `libstdc++.so.6` | `stdenv.cc.cc.lib` | C++ standard library |

**Important note:** `libxkbcommon` is NOT `xorg.libxkbcommon`. Use `libxkbcommon`.

## Example: Finding and Adding Dependencies

```bash
# Step 1: Build the package
nix-build

# Step 2: Check for missing libraries
ldd result/bin/myapp | grep "not found"
# libgtk-3.so.0 => not found
# libpulse.so.0 => not found

# Step 3: Add to buildInputs
# libgtk-3.so.0 → gtk3
# libpulse.so.0 → libpulseaudio
```

## Before

```nix
# Incomplete
buildInputs = with pkgs; [
  stdenv.cc.cc.lib
];
```

## After

```nix
# Complete
buildInputs = with pkgs; [
  stdenv.cc.cc.lib
  gtk3           # ← Added for libgtk-3.so.0
  libpulseaudio  # ← Added for libpulse.so.0
];
```

## Iterative Process

Finding dependencies is often iterative:

1. Build the package
2. Run `ldd result/bin/myapp | grep "not found"`
3. Add missing libraries to `buildInputs`
4. Rebuild
5. Repeat until no more missing libraries

## Verbose Build Output

For more debugging info:

```bash
# Build with verbose output
nix-build -K

# Keep failed build for inspection
nix-build --keep-failed

# Enter build environment
nix-shell
```

## Common Patterns

### GUI Applications

```nix
buildInputs = with pkgs; [
  # C standard library
  stdenv.cc.cc.lib

  # GTK/GUI stack
  glib gtk3 cairo pango gdk-pixbuf

  # X11
  xorg.libX11 xorg.libXcomposite xorg.libXdamage
  xorg.libXext xorg.libXfixes xorg.libXrandr

  # System
  dbus nspr nss cups libdrm mesa
];
```

### CLI Tools

```nix
buildInputs = with pkgs; [
  stdenv.cc.cc.lib  # Often enough for simple CLI tools
];
```

### Audio Applications

```nix
buildInputs = with pkgs; [
  stdenv.cc.cc.lib
  libpulseaudio  # PulseAudio
  alsa-lib       # ALSA
];
```

See [electron-apps](electron-apps.md) for Electron-specific dependencies.
