# Packaging Binary Distributions for Nix

Complete guide for extracting and patching binary packages within Nix builds for reproducibility.

## Table of Contents

- [Overview](#overview)
- [When to Use](#when-to-use)
- [Essential Pattern](#essential-pattern)
- [Archive Formats](#archive-formats)
- [Dependencies](#dependencies-the-three-categories)
- [Source Files](#source-files)
- [Common Mistakes](#common-mistakes)
- [Finding Libraries](#finding-missing-libraries)
- [Quick Testing](#quick-testing-with-steam-run)
- [Troubleshooting autoPatchelf](#troubleshooting-autopatchelf-errors)
- [Version Management](#version-management)
- [Electron Apps](#electron-apps-extra-considerations)
- [Advanced: FHS Environment](#advanced-binaries-that-resist-patching)
- [Build Phases and Hooks](#build-phases-and-hooks)
- [Wrapper Programs](#wrapper-programs-wrapprogram)
- [Real-World Impact](#real-world-impact)

---

## Overview

**Core principle:** Source from original archive directly, never from pre-extracted directories.

This ensures reproducibility across machines, works in flakes and NixOS configs, and handles version upgrades correctly.

---

## When to Use

**Use when:**
- Converting binary packages (.deb, .rpm, .tar.gz, .zip) to Nix derivations
- Packaging proprietary/closed-source software distributed as binaries
- Electron/GUI apps show "library not found" errors
- User provides pre-extracted binary contents
- Binary distributions need library path fixes

**Don't use for:**
- Software available in nixpkgs
- Source-based packages (use standard derivation)
- AppImages (use appimage-run or extract and patch)

---

## Essential Pattern

For .deb packages:

```nix
{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "appname";
  version = "1.0.0";

  # Source the archive directly
  src = ./AppName-${version}-linux-amd64.deb;

  # autoPatchelfHook fixes library paths automatically
  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    dpkg  # for .deb extraction
  ];

  # Runtime library dependencies
  buildInputs = with pkgs; [
    stdenv.cc.cc.lib
    glib
    gtk3
    # Add libraries based on ldd output
  ];

  # Extract during build (.deb format)
  unpackPhase = ''
    ar x $src
    tar xf data.tar.xz
  '';

  installPhase = ''
    mkdir -p $out
    cp -r opt/AppName/* $out/

    # Fix desktop file paths if exists
    if [ -f usr/share/applications/app.desktop ]; then
      mkdir -p $out/share/applications
      cp usr/share/applications/app.desktop $out/share/applications/
      substituteInPlace $out/share/applications/app.desktop \
        --replace-fail "/opt/AppName" "$out"
    fi
  '';
}
```

**Why this works:**
- Archives are deterministic and reproducible
- Nix handles extraction automatically in build
- autoPatchelfHook fixes library paths to Nix store
- Works on any machine with the archive file

**Anti-pattern:**
```nix
# Never do this - not reproducible
src = ./extracted-app;

# Never use absolute paths
src = /home/user/downloads/app.deb;
```

---

## Archive Formats

### RPM Packages

```nix
{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "appname";
  version = "1.0.0";
  src = ./app-${version}.x86_64.rpm;

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    rpm   # for rpm2cpio
    cpio  # for extraction
  ];

  unpackPhase = ''
    rpm2cpio $src | cpio -idmv
  '';

  installPhase = ''
    mkdir -p $out
    cp -r usr/* opt/* $out/ 2>/dev/null || true
  '';
}
```

### TAR Archives

```nix
{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "appname";
  version = "1.0.0";
  src = ./app-${version}-linux-x86_64.tar.gz;

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
  ];

  # stdenv auto-detects tar formats - no unpackPhase needed!

  installPhase = ''
    mkdir -p $out
    cp -r appname-${version}-linux-x86_64/* $out/
  '';
}
```

### ZIP Archives

```nix
{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "appname";
  version = "1.0.0";
  src = ./app-${version}-linux-x86_64.zip;

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    unzip
  ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir -p $out
    cp -r app/* $out/
  '';
}
```

### Quick Reference Table

| Format | nativeBuildInputs | unpackPhase |
|--------|-------------------|-------------|
| .deb | `autoPatchelfHook dpkg` | `ar x $src && tar xf data.tar.xz` |
| .rpm | `autoPatchelfHook rpm cpio` | `rpm2cpio $src \| cpio -idmv` |
| .tar.gz | `autoPatchelfHook` | Auto-detected |
| .tar.bz2 | `autoPatchelfHook` | Auto-detected |
| .tar.xz | `autoPatchelfHook` | Auto-detected |
| .zip | `autoPatchelfHook unzip` | `unzip $src` |

---

## Dependencies: The Three Categories

Nix has three types of dependencies:

```
┌─────────────────────────────────────────────────────────────┐
│                    What is this dependency?                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              When is it needed during the lifecycle?        │
└─────────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│nativeBuildInputs│  │  buildInputs    │  │propagatedBuild  │
│                 │  │                 │  │    Inputs       │
│Build-time tools │  │Runtime libraries│  │User dependencies│
│                 │  │                 │  │                 │
│dpkg             │  │gtk3             │  │(rarely needed)  │
│autoPatchelfHook │  │glib             │  │                 │
│makeWrapper      │  │libpulseaudio    │  │                 │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

### nativeBuildInputs

Tools needed during the build process only. NOT available at runtime.

```nix
nativeBuildInputs = with pkgs; [
  autoPatchelfHook  # Fixes library paths in binaries
  dpkg              # Extracts .deb files
  rpm               # Extracts .rpm files
  cpio              # Works with rpm for extraction
  unzip             # Extracts .zip files
  makeWrapper       # Creates wrapper scripts
  substitute        # Patches hardcoded paths
];
```

### buildInputs

Libraries the application links against at runtime. These ARE available at runtime.

```nix
buildInputs = with pkgs; [
  stdenv.cc.cc.lib    # C standard library
  glib                # GLib utility library
  gtk3                # GTK+ 3 toolkit
  gdk-pixbuf          # Image loading
  cairo               # Cairo graphics
  pango               # Text layout
  libpulseaudio       # PulseAudio
  alsa-lib            # ALSA sound
  xorg.libX11         # X11 library
  mesa                # OpenGL
];
```

### propagatedBuildInputs

Dependencies that users of your package also need. Rarely used for binary packaging.

### Common Mistake: Wrong Category

```nix
# Wrong: Libraries in nativeBuildInputs
nativeBuildInputs = with pkgs; [
  autoPatchelfHook
  gtk3    # ← Wrong! gtk3 is a runtime library
];

# Correct: Libraries in buildInputs
nativeBuildInputs = with pkgs; [ autoPatchelfHook ];
buildInputs = with pkgs; [ gtk3 ];
```

---

## Source Files

### Local Archives

```nix
{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "myapp";
  version = "1.2.3";

  # Correct: Relative path from the derivation file
  src = ./myapp-${version}-linux-x86_64.tar.gz;
}
```

### Remote Archives (fetchurl)

```nix
{ pkgs, fetchurl }:

pkgs.stdenv.mkDerivation {
  pname = "myapp";
  version = "1.2.3";

  src = fetchurl {
    url = "https://example.com/releases/myapp-${version}-linux-x86_64.tar.gz";
    hash = "sha256-AAAA...";
  };
}
```

**Getting the hash:**
```bash
# Let Nix tell you (use empty hash first)
hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

# Or compute manually
nix-hash --type sha256 --flat myapp-1.2.3.tar.gz
```

### Common Mistakes

```nix
# Wrong: Absolute paths break portability
src = /home/chumeng/Downloads/myapp.tar.gz;

# Correct: Relative path
src = ./myapp.tar.gz;

# Wrong: Pre-extracted directory not reproducible
src = ./myapp-extracted;

# Correct: Use original archive
src = ./myapp.tar.gz;
```

---

## Common Mistakes

| Mistake | Why It Fails | Fix |
|---------|--------------|-----|
| `src = ./extracted/` | Not reproducible, breaks on other machines | `src = ./app.tar.gz` |
| `src = /home/user/app.tar.gz` | Absolute path breaks portability | `src = ./app.tar.gz` |
| Missing autoPatchelfHook | Binary can't find libraries | Add to nativeBuildInputs |
| Libraries in nativeBuildInputs | Wrong category - they're runtime deps | Move to buildInputs |
| Hardcoded version in filename | Must update 2 places when upgrading | Use `src = ./app-${version}.tar.gz` |
| Wrong extractor for format | .zip fails, .rpm fails with tar | Check Quick Reference for format |

### Red Flags - STOP

If you catch yourself thinking:
- "User already extracted it, use that directory" → NO, source from original archive
- "Absolute path works for me locally" → Breaks for others, use relative
- "Just add more libraries until it works" → Find actual dependencies with `ldd`
- "Quick local test, absolute path is fine" → Bad habits stick, do it right

---

## Finding Missing Libraries

### Method 1: Run and Check Errors

```bash
# Build the package first
nix-build

# Try to run the binary
result/bin/myapp
# error while loading shared libraries: libgtk-3.so.0: cannot open shared object file
```

### Method 2: Use ldd

```bash
# Check all library dependencies
ldd result/bin/myapp | grep "not found"

# Output shows missing libraries:
# libgtk-3.so.0 => not found
# libglib-2.0.so.0 => not found
```

### Common Library Mappings

| Missing Library | Nix Package |
|-----------------|-------------|
| `libgtk-3.so.0` | `gtk3` |
| `libglib-2.0.so.0` | `glib` |
| `libpulse.so.0` | `libpulseaudio` |
| `libasound.so.2` | `alsa-lib` |
| `libGL.so.1` | `mesa` or `libglvnd` |
| `libxkbcommon.so.0` | `libxkbcommon` (NOT xorg.libxkbcommon) |
| `libX11.so.6` | `xorg.libX11` |
| `libcairo.so.2` | `cairo` |
| `libpango-1.0.so.0` | `pango` |
| `libstdc++.so.6` | `stdenv.cc.cc.lib` |

---

## Quick Testing with steam-run

Before writing a proper Nix package, use `steam-run` to quickly test if a binary works.

### What is steam-run?

`steam-run` creates an FHS-compatible environment with many common libraries pre-loaded. Originally designed for Steam games, it works for most Linux binaries.

### Quick Test

```bash
# Install steam-run
nix-shell -p steam-run

# Test any binary
steam-run ./some-app.AppImage
steam-run ./downloaded-binary
```

If it works with steam-run, you know:
- The binary is compatible with Linux
- It just needs proper dependencies
- A proper Nix package is feasible

### Typical Workflow

1. **Test Binary First**
   ```bash
   wget https://example.com/myapp-1.0.0.tar.gz
   tar xf myapp-1.0.0.tar.gz
   nix-shell -p steam-run
   steam-run ./myapp/bin/myapp
   ```

2. **If It Works, Write Proper Package**
   - Use autoPatchelfHook with discovered dependencies
   - Reference [Troubleshooting autoPatchelf](#troubleshooting-autopatchelf-errors) for systematic debugging

### Trade-offs

| Approach | Pros | Cons |
|----------|------|------|
| autoPatchelfHook | Small, pure, standard | Some effort to find deps |
| steam-run | Quick, works immediately | Huge closure (~1GB+) |
| buildFHSEnv | Medium size, configurable | More setup than steam-run |

---

## Troubleshooting autoPatchelf Errors

When `autoPatchelfHook` fails, it provides detailed error messages about missing dependencies.

### Step-by-Step Troubleshooting

**1. Read the Full Error Log**
```bash
# Get the derivation path from the error message
nix log /nix/store/...-myapp-1.0.0.drv
```

**2. Map Libraries to Nix Packages**

| Missing Library | Nix Package |
|-----------------|-------------|
| `libX11.so.6` | `xorg.libX11` |
| `libgtk-3.so.0` | `gtk3` |
| `libgtk-x11-2.0.so.0` | `gtk2` |
| `libglib-2.0.so.0` | `glib` |
| `libgdk_pixbuf-2.0.so.0` | `gdk-pixbuf` |
| `libpulse.so.0` | `libpulseaudio` |
| `libasound.so.2` | `alsa-lib` |
| `libGL.so.1` | `mesa` or `libglvnd` |
| `libxkbcommon.so.0` | `libxkbcommon` (NOT xorg.libxkbcommon) |

**3. Search for Unknown Libraries**

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

```bash
# Method 1: nix-index (recommended - fastest)
nix-env -iA nixpkgs.nix-index
nix-index  # Build file index (first time only, takes a while)
nix-locate libX11.so.6

# Method 2: NixOS Search
# Visit https://search.nixos.org/packages
```

**4. Build Iteratively**

```nix
# Start minimal, add dependencies as errors appear
buildInputs = with pkgs; [
  stdenv.cc.cc.lib  # Start with this
];
```

Build fails → add missing library → repeat.

### Complete Example: DingTalk-style Dependency Resolution

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
    # Organize by category
    stdenv.cc.cc.lib

    # GUI/GTK
    gtk3 glib cairo pango gdk-pixbuf
    at-spi2-atk at-spi2-core

    # X11
    xorg.libX11 xorg.libXcomposite xorg.libXdamage
    xorg.libXext xorg.libXfixes xorg.libXrandr

    # Audio
    alsa-lib libpulseaudio

    # System
    dbus nspr nss cups libdrm gnutls
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

---

## Version Management

### Use Version Variable in Filename

```nix
# Good: Single source of truth
pkgs.stdenv.mkDerivation rec {
  pname = "myapp";
  version = "1.2.3";
  src = ./myapp-${version}-linux-x86_64.tar.gz;
}

# Bad: Version hardcoded separately
pkgs.stdenv.mkDerivation rec {
  pname = "myapp";
  version = "1.2.3";
  src = ./myapp-1.2.2-linux-x86_64.tar.gz;  # Mismatch!
}
```

When you update version, the filename updates automatically. No need to remember to change both places.

---

## Electron Apps: Extra Considerations

Electron apps bundle Chromium and Node.js, requiring extensive dependencies.

```nix
{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "myapp";
  version = "1.0.0";
  src = ./myapp-${version}-linux-x86_64.tar.gz;

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = with pkgs; [
    # Base
    stdenv.cc.cc.lib

    # GTK/GUI stack
    glib gtk3 cairo pango gdk-pixbuf
    at-spi2-atk at-spi2-core

    # X11
    xorg.libX11 xorg.libXcomposite xorg.libXdamage
    xorg.libXext xorg.libXfixes xorg.libXrandr
    libxkbcommon libdrm

    # Audio
    alsa-lib libpulseaudio

    # System
    dbus nspr nss cups libdrm mesa
  ];

  installPhase = ''
    mkdir -p $out/share/myapp
    cp -r * $out/share/myapp/
  '';

  postInstall = ''
    makeWrapper $out/share/myapp/myapp $out/bin/myapp \
      --add-flags "--disable-gpu-sandbox"
  '';
}
```

---

## Advanced: Binaries That Resist Patching

Some proprietary software detects modifications (license/DRM checks) and refuses to run. For these, autoPatchelfHook won't work.

### Solution: FHS Environment with Bubblewrap

```nix
{ pkgs }:

pkgs.buildFHSEnv {
  name = "myapp";
  targetPkgs = pkgs: with pkgs; [
    # All runtime dependencies
    glib gtk3 openssl
  ];

  runScript = "${extracted}/bin/myapp";
}
```

Or use `steam-run` for quick testing:

```bash
nix-shell -p steam-run
steam-run ./myapp
```

**Trade-off:** Larger closure size, less reproducible than autoPatchelfHook.

---

## Build Phases and Hooks

Nix derivations run through 7 standard phases:

```
unpack → patch → configure → build → check → install → fixup
```

### Customizing Phases

```nix
stdenv.mkDerivation {
  # Before unpacking
  preUnpack = ''
    echo "About to extract..."
  '';

  # After patching, before configure
  postPatch = ''
    # Fix hardcoded paths
    substituteInPlace Makefile \
      --replace "/usr/bin" "$out/bin"
  '';

  # After installation
  postInstall = ''
    # Wrap binary with runtime dependencies
    wrapProgram $out/bin/myapp \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg ]}
  '';
}
```

### For Binary Packages

Binary packages typically skip configure/build:

```nix
stdenv.mkDerivation {
  # Custom unpack
  unpackPhase = ''
    ar x $src
    tar xf data.tar.xz
  '';

  # Skip configure and build
  configurePhase = "true";
  buildPhase = "true";

  # Install the binary
  installPhase = ''
    mkdir -p $out/bin
    cp myapp $out/bin/myapp
  '';

  # No tests
  doCheck = false;
}
```

---

## Wrapper Programs: wrapProgram

When binaries need specific environment variables or PATH entries:

```nix
nativeBuildInputs = [ makeWrapper ];

postInstall = ''
  wrapProgram $out/bin/myapp \
    --prefix PATH : "${lib.makeBinPath [ ffmpeg imagemagick ]}" \
    --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ vulkan-loader ]}" \
    --set QT_QPA_PLATFORM "xcb" \
    --add-flags "--disable-telemetry"
'';
```

### Common Wrapper Options

- `--prefix PATH : "path"` - Add tools to PATH
- `--set VAR "value"` - Set environment variable
- `--add-flags "flags"` - Add default command-line flags
- `--prefix LD_LIBRARY_PATH : "path"` - Add library search path

### Complete Example

```nix
{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "myapp";
  version = "1.0.0";
  src = ./myapp-${version}.tar.gz;

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = with pkgs; [
    stdenv.cc.cc.lib
    glib
    gtk3
  ];

  installPhase = ''
    mkdir -p $out/opt/myapp
    cp -r * $out/opt/myapp/
  '';

  postInstall = ''
    wrapProgram $out/opt/myapp/myapp $out/bin/myapp \
      --prefix PATH : "${lib.makeBinPath [ ffmpeg ]}" \
      --set MYAPP_DATA_DIR "$out/opt/myapp/data" \
      --add-flags "--disable-gpu-sandbox"
  '';
}
```

---

## Real-World Impact

**Without this pattern:**
- Package works on your machine only
- Breaks when shared or used in flakes
- Manual extraction required before every build
- Version mismatches go unnoticed
- Format-specific extraction errors

**With this pattern:**
- Fully reproducible across machines
- Works in flakes, NixOS configs, nix-env
- Automatic extraction on every build
- Version changes = single line edit
- Handles .deb, .rpm, .tar.gz, .zip consistently

---

## Quick Reference

| Task | Solution |
|------|----------|
| Local archive | `src = ./package-${version}.tar.gz` |
| Remote archive | `src = fetchurl { url = "..."; hash = "sha256-..."; }` |
| Extract .deb | `ar x $src && tar xf data.tar.xz` + dpkg |
| Extract .rpm | `rpm2cpio $src \| cpio -idmv` + rpm, cpio |
| Extract .tar.gz | Auto-detected by stdenv |
| Extract .zip | Add `unzip` to nativeBuildInputs |
| Fix libraries | Add `autoPatchelfHook` to nativeBuildInputs |
| Find missing libs | Run binary, check errors, add to buildInputs |
| Quick testing | `nix-shell -p steam-run; steam-run ./binary` |
| Debug autoPatchelf | `nix log /nix/store/...-drv` |
| Search libraries | `nix-locate libX11.so.6` |
| Wrapper scripts | Use `makeWrapper` in nativeBuildInputs |
| Version sync | Use `${version}` in filename |

