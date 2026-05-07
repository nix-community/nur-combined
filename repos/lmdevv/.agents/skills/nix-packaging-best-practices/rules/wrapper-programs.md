---
title: Wrapper Programs with wrapProgram
impact: MEDIUM
impactDescription: Wrappers set environment variables and add default flags
tags: wrapper, makeWrapper, environment, flags, path
---

## Wrapper Programs with wrapProgram

When binaries need specific environment variables, PATH entries, or command-line flags, use wrapper scripts.

## Basic Usage

```nix
{ pkgs }:

pkgs.stdenv.mkDerivation {
  # ... other derivation attributes

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    makeWrapper  # ← Required for wrapProgram
  ];

  postInstall = ''
    # Create wrapper script
    wrapProgram $out/bin/myapp \
      --prefix PATH : "${lib.makeBinPath [ ffmpeg imagemagick ]}" \
      --set MY_VAR "value" \
      --add-flags "--some-flag"
  '';
}
```

## What is a Wrapper?

A wrapper is a shell script that:
1. Sets up environment variables
2. Extends PATH with needed tools
3. Adds default command-line flags
4. Then executes the actual binary

**Without wrapper:**
```bash
$result/bin/myapp  # Binary might fail without proper env
```

**With wrapper:**
```bash
$result/bin/myapp  # Wrapper sets env, then runs binary
```

## Common Wrapper Options

### --prefix PATH : "path"

Add tools to PATH:

```nix
postInstall = ''
  wrapProgram $out/bin/myapp \
    --prefix PATH : "${lib.makeBinPath [ ffmpeg imagemagick ]}"
'';
```

Now the binary can find `ffmpeg` and `convert` (ImageMagick).

### --set VAR "value"

Set environment variable:

```nix
postInstall = ''
  wrapProgram $out/bin/myapp \
    --set QT_QPA_PLATFORM "xcb" \
    --set GDK_BACKEND "x11"
'';
```

### --add-flags "flags"

Add default command-line flags:

```nix
postInstall = ''
  wrapProgram $out/bin/myapp \
    --add-flags "--disable-gpu-sandbox" \
    --add-flags "--no-sandbox"
'';
```

Equivalent to:
```bash
myapp --disable-gpu-sandbox --no-sandbox
```

### --prefix LD_LIBRARY_PATH : "path"

Add library search path (rare, autoPatchelfHook usually handles this):

```nix
postInstall = ''
  wrapProgram $out/bin/myapp \
    --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ vulkan-loader ]}"
'';
```

### --argv0 "name"

Change process name (argv[0]):

```nix
postInstall = ''
  wrapProgram $out/bin/myapp \
    --argv0 "myapp"
'';
```

## Combining Options

```nix
postInstall = ''
  wrapProgram $out/bin/myapp \
    --prefix PATH : "${lib.makeBinPath [ ffmpeg ]}" \
    --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ vulkan-loader ]}" \
    --set QT_QPA_PLATFORM "xcb" \
    --set WAYLAND_DISPLAY "" \
    --add-flags "--disable-gpu-sandbox" \
    --add-flags "--enable-features=UseOzonePlatform"
'';
```

## Multiple Wrappers

Wrap multiple programs:

```nix
postInstall = ''
  # Wrap main binary
  wrapProgram $out/bin/myapp \
    --prefix PATH : "${lib.makeBinPath [ ffmpeg ]}"

  # Wrap secondary tool
  wrapProgram $out/bin/mytool \
    --set MYTOOL_VAR "value"
'';
```

## makeBinPath and makeLibraryPath

Helper functions to build colon-separated paths:

```nix
# makeBinPath: adds /bin subdirectories
lib.makeBinPath [ pkgs.ffmpeg pkgs.imagemagick ]
# → /nix/store/...-ffmpeg/bin:/nix/store/...-imagemagick/bin

# makeLibraryPath: adds /lib subdirectories
lib.makeLibraryPath [ pkgs.vulkan-loader pkgs.mesa ]
# → /nix/store/...-vulkan-loader/lib:/nix/store/...-mesa/lib

# makeSearchPath: custom subdirectory
lib.makeSearchPath "share/myapp" [ pkgs.myapp-data ]
# → /nix/store/...-myapp-data/share/myapp
```

## Real-World Examples

### GUI Application

```nix
postInstall = ''
  wrapProgram $out/bin/myapp \
    --set QT_QPA_PLATFORM "xcb" \
    --set GDK_BACKEND "x11" \
    --add-flags "--disable-gpu-sandbox"
'';
```

### CLI Tool with Dependencies

```nix
postInstall = ''
  wrapProgram $out/bin/mytool \
    --prefix PATH : "${lib.makeBinPath [ ffmpeg sox ]}"
'';
```

### Application with Plugins

```nix
postInstall = ''
  wrapProgram $out/bin/myapp \
    --set MYAPP_PLUGINS_DIR "$out/lib/myapp/plugins" \
    --set MYAPP_DATA_DIR "$out/share/myapp"
'';
```

### Electron App with Flags

```nix
postInstall = ''
  wrapProgram $out/share/myapp/myapp $out/bin/myapp \
    --prefix PATH : "${lib.makeBinPath [ ffmpeg ]}" \
    --add-flags "--disable-gpu-sandbox" \
    --add-flags "--enable-features=WaylandWindowDecorations"
'';
```

## makeWrapper for Creating Wrappers

Alternative to wrapProgram, gives more control:

```nix
postInstall = ''
  makeWrapper $out/opt/myapp/myapp $out/bin/myapp \
    --prefix PATH : "${lib.makeBinPath [ ffmpeg ]}" \
    --set MY_VAR "value"
'';
```

**Difference:**
- `wrapProgram` - Wraps existing file in-place
- `makeWrapper` - Creates wrapper at different location

```nix
# wrapProgram: modifies $out/bin/myapp
wrapProgram $out/bin/myapp ...

# makeWrapper: creates new wrapper
makeWrapper $out/opt/myapp/myapp $out/bin/myapp ...
```

## When to Use Wrappers

**Use wrappers when:**
- Binary needs tools on PATH (ffmpeg, imagemagick, etc.)
- Binary requires specific environment variables
- Adding default command-line flags
- Setting plugin/data directories
- Customizing runtime behavior

**Don't need wrappers when:**
- Binary works standalone (just needs libraries)
- autoPatchelfHook handles all dependencies
- No environment variables needed

## Complete Example

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

    mkdir -p $out/bin
  '';

  postInstall = ''
    # Create wrapper with PATH, env vars, and flags
    wrapProgram $out/opt/myapp/myapp $out/bin/myapp \
      --prefix PATH : "${lib.makeBinPath [ ffmpeg ]}" \
      --set MYAPP_DATA_DIR "$out/opt/myapp/data" \
      --set QT_QPA_PLATFORM "xcb" \
      --add-flags "--disable-gpu-sandbox"
  '';

  meta = with pkgs.lib; {
    description = "MyApp with wrapper";
  };
}
```

## Debugging Wrappers

See what the wrapper does:

```bash
# View the wrapper script
cat result/bin/myapp

# Run with bash debug
bash -x result/bin/myapp

# Check environment
result/bin/myapp --help
```

The wrapper is a bash script that sets environment then runs the binary.
