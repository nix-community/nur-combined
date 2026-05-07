---
title: The Core Pattern
impact: CRITICAL
impactDescription: Foundational principle for reproducible binary packaging
tags: binary, packaging, reproducibility, archives, core-pattern
---

## The Core Pattern

**Source from original archive directly, never from pre-extracted directories.**

For .deb packages:

```nix
{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "appname";
  version = "1.0.0";

  # ✅ Source the archive directly
  src = ./AppName-${version}-linux-amd64.deb;

  # ✅ autoPatchelfHook fixes library paths automatically
  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    dpkg  # for .deb extraction
  ];

  # ✅ Runtime library dependencies
  buildInputs = with pkgs; [
    stdenv.cc.cc.lib
    glib
    gtk3
    # Add libraries based on ldd output
  ];

  # ✅ Extract during build (.deb format)
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

## Why This Matters

- **Reproducibility**: Archives are deterministic, extracted directories vary
- **Portability**: Works on any machine with the archive file
- **Automation**: Nix handles extraction automatically in build
- **Version Control**: Single source of truth for package contents

## Incorrect

```nix
# ❌ Never do this - not reproducible
src = ./extracted-app;

# ❌ Never use absolute paths
src = /home/user/downloads/app.deb;
```

## Correct

```nix
# ✅ Always source from original archive
src = ./AppName-${version}-linux-amd64.deb;
```

## Next Steps

- See [archive-formats](archive-formats.md) for other package types
- See [dependencies](dependencies.md) for dependency categories
- See [finding-libraries](finding-libraries.md) for identifying missing libs
