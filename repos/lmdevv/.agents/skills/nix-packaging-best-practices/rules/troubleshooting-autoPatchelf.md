---
title: Troubleshooting autoPatchelf Errors
impact: HIGH
impactDescription: Systematic debugging approach for dependency errors
tags: troubleshooting, debugging, autoPatchelf, errors, dependencies
---

## Troubleshooting autoPatchelf Errors

When `autoPatchelfHook` fails, it provides detailed error messages about missing dependencies.

## Common Error Pattern

```bash
# autoPatchelfHook will fail with:
error: auto-patchelf could not satisfy dependency libX11.so.6 wanted by /nix/store/...-myapp-1.0/bin/myapp

error: auto-patchelf could not satisfy dependency libgtk-3.so.0 wanted by /nix/store/...-myapp-1.0/lib/myapp

# For full logs, run 'nix log /nix/store/...-myapp-1.0.0.drv'
```

## Step-by-Step Troubleshooting

### 1. Read the Full Error Log

```bash
# Get the derivation path from the error message
nix log /nix/store/gm3d0jm6l19ypcz6vfmv5hmx8d9iygr1-myapp-1.0.0.drv
```

This shows all missing dependencies at once.

### 2. Map Libraries to Nix Packages

| Missing Library | Nix Package |
|-----------------|-------------|
| `libX11.so.6` | `xorg.libX11` |
| `libgtk-3.so.0` | `gtk3` |
| `libgtk-x11-2.0.so.0` | `gtk2` |
| `libglib-2.0.so.0` | `glib` |
| `libgobject-2.0.so.0` | `glib` |
| `libgdk_pixbuf-2.0.so.0` | `gdk-pixbuf` |
| `libpulse.so.0` | `libpulseaudio` |
| `libasound.so.2` | `alsa-lib` |
| `libGL.so.1` | `mesa` or `libglvnd` |
| `libxkbcommon.so.0` | `libxkbcommon` (NOT xorg.libxkbcommon) |
| `libdrm.so.2` | `libdrm` |

### 3. Search for Unknown Libraries

**What is nix-locate?**

`nix-locate` is a command from the **`nix-index`** package that searches for files across all Nix packages. When you need to find which package provides a library (like `libX11.so.6`), `nix-locate` tells you instantly.

```bash
# Search for which package provides a library
nix-locate libX11.so.6
# Output: nixpkgs.xorg.libX11

# Search for binaries
nix-locate bin/ffmpeg
# Output: nixpkgs.ffmpeg
```

Without `nix-locate`, you'd have to:
- Manually search https://search.nixos.org/packages (slow)
- Grep through nixpkgs source code (very slow)
- Guess based on experience (unreliable)

**Method 1: nix-index (recommended - fastest)**
```bash
# 1. Install nix-index
nix-env -iA nixpkgs.nix-index

# 2. Build the file index (takes a while, first time only)
nix-index

# 3. Search for files
nix-locate libX11.so.6
# → nixpkgs.xorg.libX11

# 4. Use the result in your derivation
buildInputs = [ pkgs.xorg.libX11 ];
```

**Method 2: NixOS Search**
```bash
# Visit https://search.nixos.org/packages
# Search for the library name (e.g., "libX11")
```

**Method 3: grep nixpkgs**
```bash
# Clone nixpkgs if you haven't
cd ~/src/nixpkgs

# Search for the library in outputs
grep -r "libX11.so.6" .
```

### 4. Build Iteratively

```nix
# First attempt - minimal dependencies
{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "myapp";
  version = "1.0.0";
  src = ./myapp-${version}.tar.gz;

  nativeBuildInputs = [ pkgs.autoPatchelfHook ];

  buildInputs = with pkgs; [
    stdenv.cc.cc.lib  # Start with this
  ];
}
```

Build fails → add missing library → repeat.

### 5. Handle Complex Dependencies

Some apps have 30+ dependencies (like DingTalk). Group them:

```nix
{ pkgs }:

let
  # Organize by category
  guiLibs = with pkgs; [
    gtk3
    cairo
    pango
    gdk-pixbuf
    at-spi2-atk
    at-spi2-core
  ];

  x11Libs = with pkgs; [
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
  ];

  systemLibs = with pkgs; [
    dbus
    nspr
    nss
    cups
    libdrm
  ];

in pkgs.stdenv.mkDerivation {
  # ...
  buildInputs = guiLibs ++ x11Libs ++ systemLibs;
}
```

## Special Cases

### Libraries Bundled with App

Some apps ship their own libraries. Remove them:

```nix
unpackPhase = ''
  ar x ${src}
  tar xf data.tar.xz

  # Remove bundled libraries that system provides
  rm -f release/libgtk-x11-2.0.so.*
  rm -f release/libm.so.*
'';
```

### Dynamic Loading at Runtime

If the app loads libraries dynamically (plugins), add to `LD_LIBRARY_PATH`:

```nix
nativeBuildInputs = [ pkgs.makeWrapper ];

postInstall = ''
  makeWrapper $out/lib/myapp $out/bin/myapp \
    --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"
'';
```

### 32-bit Libraries on 64-bit System

```nix
# Use pkgsi686Linux for 32-bit libraries
buildInputs = with pkgs; [
  stdenv.cc.cc.lib
  pkgsi686Linux.glib
  pkgsi686Linux.gtk3
];
```

## Quick Debugging Commands

```bash
# After successful build, check dependencies
ldd result/bin/myapp | grep "not found"

# Enter the failed build environment
nix-shell --pure
nix-build --keep-failed
cd /tmp/nix-build-*

# Check what files were extracted
find . -type f -executable

# Check library dependencies
ldd ./some-binary
```

## Complete Example: DingTalk-style Dependency Resolution

```nix
{ pkgs, lib, ... }@args:

pkgs.stdenv.mkDerivation rec {
  pname = "myapp";
  version = "1.0.0";
  src = ./myapp-${version}.deb;

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    dpkg
    makeWrapper
  ];

  buildInputs = with pkgs; [
    # C library
    stdenv.cc.cc.lib

    # GUI/GTK
    gtk3 glib cairo pango gdk-pixbuf

    # Accessibility
    at-spi2-atk at-spi2-core

    # X11
    xorg.libX11 xorg.libXcomposite xorg.libXdamage
    xorg.libXext xorg.libXfixes xorg.libXrandr

    # Audio
    alsa-lib libpulseaudio

    # System
    dbus nspr nss cups libdrm

    # Network
    gnutls
  ];

  unpackPhase = ''
    ar x ${src}
    tar xf data.tar.xz
  '';

  installPhase = ''
    mkdir -p $out
    cp -r opt/* $out/

    # App loads libraries at runtime
    makeWrapper $out/myapp $out/bin/myapp \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"
  '';
}
```

## References

- [nix-index](https://github.com/bennofs/nix-index) - Fast file-to-package lookup
- [NixOS Search](https://search.nixos.org/packages) - Package search
- [Finding libraries](finding-libraries.md) - Library mappings

## See Also

- [finding-libraries](finding-libraries.md) - Common library mappings
- [dependencies](dependencies.md) - Dependency categories
