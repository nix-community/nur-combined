---
title: Packaging Electron Applications
impact: HIGH
impactDescription: Electron apps bundle Chromium and Node.js requiring extensive dependencies
tags: electron, gui, dependencies, chromium, nodejs
---

## Packaging Electron Applications

Electron apps bundle Chromium and Node.js, requiring extensive dependencies.

## Common Electron Dependencies

Most Electron applications need these libraries:

```nix
{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "myapp";
  version = "1.0.0";
  src = ./myapp-${version}-linux-x86_64.tar.gz;

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
  ];

  buildInputs = with pkgs; [
    # C standard library
    stdenv.cc.cc.lib

    # GTK/GUI stack
    glib
    gtk3
    cairo
    pango
    gdk-pixbuf
    at-spi2-atk
    at-spi2-core

    # X11/Wayland
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libXrender
    libxkbcommon
    libdrm

    # Audio
    alsa-lib
    libpulseaudio

    # System
    dbus
    nspr
    nss
    cups

    # Graphics
    mesa

    # Network
    openssl
  ];

  installPhase = ''
    mkdir -p $out/share/myapp
    cp -r * $out/share/myapp/

    mkdir -p $out/bin
    ln -s $out/share/myapp/myapp $out/bin/myapp
  '';
}
```

## GPU Sandbox Flags

Electron apps often need GPU sandbox disabled:

```nix
nativeBuildInputs = with pkgs; [
  autoPatchelfHook
  makeWrapper
];

postInstall = ''
  makeWrapper $out/share/myapp/myapp $out/bin/myapp \
    --add-flags "--disable-gpu-sandbox"
'';
```

## Desktop Entry

Many Electron apps include desktop files that need path fixing:

```nix
installPhase = ''
  mkdir -p $out/share/myapp
  cp -r * $out/share/myapp/

  # Fix desktop file if present
  if [ -f usr/share/applications/myapp.desktop ]; then
    mkdir -p $out/share/applications
    cp usr/share/applications/myapp.desktop $out/share/applications/

    substituteInPlace $out/share/applications/myapp.desktop \
      --replace-fail "/opt/MyApp" "$out/share/myapp" \
      --replace-fail "/usr/bin/myapp" "$out/bin/myapp"
  fi

  # Copy icons if present
  if [ -d usr/share/icons ]; then
    cp -r usr/share/icons/* $out/share/icons/
  fi

  mkdir -p $out/bin
  ln -s $out/share/myapp/myapp $out/bin/myapp
'';
```

## Minimal Electron Dependencies

Start minimal and add based on `ldd` output:

```nix
buildInputs = with pkgs; [
  stdenv.cc.cc.lib  # Always needed
  glib              # Almost always needed
  gtk3              # GUI apps
  # Add more based on ldd errors
];
```

## Testing Electron Apps

```bash
# After building
nix-build

# Run and check for missing libraries
result/bin/myapp

# Check with ldd
ldd result/share/myapp/myapp | grep "not found"
```

## Common Electron Error Messages

| Error | Missing Library | Nix Package |
|-------|-----------------|-------------|
| `error while loading shared libraries: libgtk-3.so.0` | GTK | `gtk3` |
| `error while loading shared libraries: libgobject-2.0.so.0` | GLib | `glib` |
| `error while loading shared libraries: libX11.so.6` | X11 | `xorg.libX11` |
| `error while loading shared libraries: libGL.so.1` | OpenGL | `mesa` |
| `error while loading shared libraries: libpulse.so.0` | PulseAudio | `libpulseaudio` |
| `error while loading shared libraries: libasound.so.2` | ALSA | `alsa-lib` |
| GPU rendering issues | GPU sandbox | Add `--disable-gpu-sandbox` flag |

## Wayland Support

For Electron apps supporting Wayland:

```nix
postInstall = ''
  makeWrapper $out/share/myapp/myapp $out/bin/myapp \
    --add-flags "--disable-gpu-sandbox" \
    --add-flags "--ozone-platform=wayland" \
    --set WAYLAND_DISPLAY ''${WAYLAND_DISPLAY-}
'';
```

## Complete Electron Example

```nix
{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "my-electron-app";
  version = "1.2.3";

  src = ./myapp-${version}-linux-x86_64.tar.gz;

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = with pkgs; [
    stdenv.cc.cc.lib
    glib gtk3 cairo pango gdk-pixbuf
    at-spi2-atk at-spi2-core
    xorg.libX11 xorg.libXcomposite xorg.libXdamage
    xorg.libXext xorg.libXfixes xorg.libXrandr
    libxkbcommon libdrm
    alsa-lib libpulseaudio
    dbus nspr nss cups mesa
  ];

  installPhase = ''
    mkdir -p $out/share/myapp
    cp -r * $out/share/myapp/

    # Desktop entry
    if [ -f myapp.desktop ]; then
      mkdir -p $out/share/applications
      cp myapp.desktop $out/share/applications/
      substituteInPlace $out/share/applications/myapp.desktop \
        --replace-fail "/opt/myapp" "$out/share/myapp"
    fi

    # Icons
    if [ -d usr/share/icons ]; then
      cp -r usr/share/icons/* $out/share/icons/ 2>/dev/null || true
    fi

    # Wrapper
    mkdir -p $out/bin
    makeWrapper $out/share/myapp/myapp $out/bin/myapp \
      --add-flags "--disable-gpu-sandbox"
  '';

  meta = with pkgs.lib; {
    description = "My Electron App";
    platforms = [ "x86_64-linux" ];
  };
}
```

## Alternative: Using appimage-run

For quick testing without full packaging:

```bash
# If app is distributed as AppImage
nix-shell -p appimage-run
appimage-run ./myapp.AppImage
```

This isn't a proper Nix package but helps verify dependencies.

## Finding Missing Libraries

See [finding-libraries](finding-libraries.md) for comprehensive guide on identifying missing Electron dependencies.
