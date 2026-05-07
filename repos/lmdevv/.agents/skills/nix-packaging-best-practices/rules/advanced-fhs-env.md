---
title: FHS Environment for Resistant Binaries
impact: LOW
impactDescription: For binaries that detect modifications and refuse to run
tags: fhs, buildfhsenv, bubblewrap, drm, advanced, resistant-binaries
---

## Advanced: FHS Environment for Resistant Binaries

Some proprietary binaries detect modifications (like autoPatchelfHook) and refuse to run due to license checks, DRM, or integrity validation.

## The Problem

## Incorrect

```nix
# ❌ This might break the binary
pkgs.stdenv.mkDerivation {
  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  # Some binaries detect rpath modifications and crash
  # Error: "Integrity check failed" or "Invalid executable"
}
```

## The Solution: buildFHSEnv

Create a Filesystem Hierarchy Standard (FHS) environment using Bubblewrap to provide traditional Linux paths.

```nix
{ pkgs }:

pkgs.buildFHSEnv {
  name = "myapp";
  targetPkgs = pkgs: with pkgs; [
    # All runtime dependencies
    glib
    gtk3
    openssl
    libpulseaudio
    alsa-lib
    # ... any other libraries
  ];

  runScript = "${extracted-binary}/bin/myapp";
}
```

## How It Works

- **Bubblewrap** creates a container with traditional paths (`/usr/lib`, `/lib`, etc.)
- Binary sees the environment it expects, passes integrity checks
- Nix packages are symlinked into FHS paths
- No modification of the binary itself

## Quick Testing with steam-run

For rapid prototyping:

```nix
{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "myapp";
  version = "1.0.0";
  src = ./myapp.tar.gz;

  buildInputs = with pkgs; [
    steam-run  # Includes many common libraries
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp myapp $out/bin/myapp
  '';

  postFixup = ''
    patchShebangs $out/bin/myapp

    # Wrap with steam-run
    wrapProgram $out/bin/myapp \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.steam-run ]}
  '';
}
```

Or run directly:

```bash
nix-shell -p steam-run
steam-run ./myapp
```

## buildFHSEnv Complete Example

```nix
{ pkgs }:

let
  # First, build the binary extraction
  extracted-binary = pkgs.stdenv.mkDerivation {
    pname = "myapp-extracted";
    version = "1.0.0";
    src = ./myapp.tar.gz;

    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };

in pkgs.buildFHSEnv {
  name = "myapp";
  targetPkgs = pkgs: with pkgs; [
    # C library
    stdenv.cc.cc.lib

    # GUI
    glib
    gtk3
    cairo
    pango
    gdk-pixbuf

    # X11
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr

    # Audio
    alsa-lib
    libpulseaudio

    # System
    dbus
    nspr
    nss
    cups
  ];

  multiPkgs = pkgs: with pkgs; [
    # Packages available for both target and build
    # Usually needed for compilers/build tools
  ];

  runScript = "${extracted-binary}/myapp";
}
```

## When to Use FHS Env

**Use buildFHSEnv when:**
- Binary has DRM/anti-tamper that detects modifications
- License verification fails after patching
- Binary assumes specific FHS paths (`/usr/lib`, etc.)
- Quick prototyping before proper packaging
- Legacy applications with hard-coded paths

**Don't use when:**
- Standard autoPatchelfHook works (preferred)
- Binary tolerates rpath modifications
- Closure size matters (FHS env is larger)

## Trade-offs

| Approach | Pros | Cons |
|----------|------|------|
| autoPatchelfHook | Small closure, reproducible, standard | Some binaries reject it |
| buildFHSEnv | Works for resistant binaries, traditional paths | Larger closure, less pure |
| steam-run | Quick testing | Massive closure, not for production |

## FHS vs autoPatchelfHook

## autoPatchelfHook (preferred)

```nix
# - Modifies binary's rpath
# - Small closure
# - Standard approach
pkgs.stdenv.mkDerivation {
  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  buildInputs = [ pkgs.glib pkgs.gtk3 ];
}
```

## buildFHSEnv (when autoPatchelfHook fails)

```nix
# - Creates FHS environment
# - Larger closure
# - For resistant binaries only
pkgs.buildFHSEnv {
  targetPkgs = pkgs: [ pkgs.glib pkgs.gtk3 ];
  runScript = "binary";
}
```

## Finding FHS Dependencies

Same process as autoPatchelfHook:

```bash
# Try running binary
./myapp

# Check ldd
ldd ./myapp | grep "not found"

# Add missing libraries to targetPkgs
```

## Combining Approaches

You can provide both options:

```nix
{ pkgs }:

# Standard packaging
myapp-standard = pkgs.stdenv.mkDerivation {
  # ... autoPatchelfHook approach
};

# FHS fallback
myapp-fhs = pkgs.buildFHSEnv {
  # ... FHS approach
};

# Let user choose
in {
  inherit myapp-standard;
  inherit myapp-fhs;
  default = myapp-standard;
}
```

## Real-World Example

Some games with DRM (e.g., certain Unity games) require FHS env:

```nix
{ pkgs }:

pkgs.buildFHSEnv {
  name = "mygame";
  targetPkgs = pkgs: with pkgs; [
    steam-run  # Includes many game dependencies
    SDL2
    SDL
    openal
    ffmpeg
    libpulseaudio
    alsa-lib
  ];

  runScript = "/path/to/mygame";
}
```

## References

- [buildFHSEnv documentation](https://nixos.org/manual/nixpkgs/stable/#ssec-pkgs-buildFHSEnv)
- [Bubblewrap](https://github.com/containers/bubblewrap)
- [Steam-run source](https://github.com/NixOS/nixpkgs/blob/master/pkgs/games/steam/steam-run/default.nix)
