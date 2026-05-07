---
title: Format-Specific Extraction
impact: HIGH
impactDescription: Different archive formats require different extraction methods and tools
tags: archives, extraction, deb, rpm, tar, zip, formats
---

## Format-Specific Extraction

Different binary distribution formats require different extraction methods.

## RPM Packages

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

  # RPM extracts to current directory
  installPhase = ''
    mkdir -p $out
    cp -r usr/* opt/* $out/ 2>/dev/null || true
  '';
}
```

## TAR Archives (.tar.gz, .tar.bz2, .tar.xz)

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

## ZIP Archives

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

## Debian Packages (.deb)

See [essential-pattern](essential-pattern.md) for full .deb example.

## Quick Reference Table

| Format | nativeBuildInputs | unpackPhase |
|--------|-------------------|-------------|
| .deb | `autoPatchelfHook dpkg` | `ar x $src && tar xf data.tar.xz` |
| .rpm | `autoPatchelfHook rpm cpio` | `rpm2cpio $src \| cpio -idmv` |
| .tar.gz | `autoPatchelfHook` | Auto-detected |
| .tar.bz2 | `autoPatchelfHook` | Auto-detected |
| .tar.xz | `autoPatchelfHook` | Auto-detected |
| .zip | `autoPatchelfHook unzip` | `unzip $src` |

## Incorrect

```nix
# ❌ Wrong - using tar for .zip
unpackPhase = ''
  tar xf $src  # This will fail
'';

# ❌ Wrong - .deb extraction requires dpkg
nativeBuildInputs = [ autoPatchelfHook ];  # Missing dpkg
```

## Correct

```nix
# ✅ Correct - match format to tools
nativeBuildInputs = [ autoPatchelfHook dpkg ];
unpackPhase = ''
  ar x $src && tar xf data.tar.xz
'';
```
