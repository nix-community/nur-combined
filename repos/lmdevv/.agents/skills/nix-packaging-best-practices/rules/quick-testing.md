---
title: Quick Testing with steam-run
impact: MEDIUM
impactDescription: Rapid prototyping before writing proper Nix package
tags: steam-run, testing, prototyping, debugging, quick
---

## Quick Testing with steam-run

Before writing a proper Nix package, use `steam-run` to quickly test if a binary works.

## What is steam-run?

`steam-run` is a script that uses Bubblewrap to create an FHS-compatible environment with many common libraries pre-loaded. Originally designed for Steam games, it works for most Linux binaries.

## Quick Test

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

## Typical Workflow

### 1. Test Binary First

```bash
# Download binary
wget https://example.com/myapp-1.0.0.tar.gz
tar xf myapp-1.0.0.tar.gz

# Test with steam-run
nix-shell -p steam-run
steam-run ./myapp/bin/myapp
```

### 2. If It Works, Write Proper Package

```nix
{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "myapp";
  version = "1.0.0";
  src = ./myapp-${version}.tar.gz;

  nativeBuildInputs = [ pkgs.autoPatchelfHook ];

  buildInputs = with pkgs; [
    stdenv.cc.cc.lib
    glib
    gtk3
    # Add dependencies discovered through testing
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp myapp $out/bin/
  '';
}
```

### 3. If autoPatchelf Fails

Check [troubleshooting-autoPatchelf](troubleshooting-autoPatchelf.md) for systematic debugging.

## steam-run in Packages

You can also use steam-run as a fallback:

```nix
{ pkgs }:

let
  # Build the binary extraction
  myapp-binary = pkgs.stdenv.mkDerivation {
    pname = "myapp-binary";
    version = "1.0.0";
    src = ./myapp-${version}.tar.gz;

    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };

in pkgs.steam.run.override {
  # Add additional packages to the steam-run environment
  extraPkgs = pkgs: [ myapp-binary pkgs.someDependency ];
}
```

This creates a `steam-run` environment with your binary in it.

## When to Use steam-run

**Use steam-run when:**
- Quick initial testing of downloaded binaries
- Verifying a binary works before writing package
- Prototyping dependency list
- Apps with complex, hard-to-identify dependencies
- Fallback when autoPatchelfHook is too difficult

**Don't use steam-run in production when:**
- You can use autoPatchelfHook (preferred)
- Closure size matters (steam-run is huge)
- You need a proper, minimal package

## Trade-offs

| Approach | Pros | Cons |
|----------|------|------|
| autoPatchelfHook | Small, pure, standard | Some effort to find deps |
| steam-run | Quick, works immediately | Huge closure (~1GB+) |
| buildFHSEnv | Medium size, configurable | More setup than steam-run |

## Example: Testing Downloaded Binary

```bash
# 1. Download
wget https://example.com/myapp.AppImage

# 2. Make executable
chmod +x myapp.AppImage

# 3. Test
nix-shell -p steam-run
steam-run ./myapp.AppImage

# 4. If works, write package
# Now you know it's worth the effort to package properly
```

## steam-run vs buildFHSEnv

Both use Bubblewrap, but:

**steam-run:**
- Pre-configured for games
- Has 100+ libraries included
- Quick to use
- Larger closure

**buildFHSEnv:**
- You specify exact dependencies
- Smaller closure
- More control
- More setup required

## Complete Example

```nix
{ pkgs }:

# Quick test with steam-run
let
  test-binary = pkgs.runCommand "test-myapp" {
    buildInputs = [ pkgs.steam-run ];
  } ''
    mkdir -p $out
    cp ${./myapp} $out/myapp
  '';

in pkgs.writeShellScript "test" ''
  ${pkgs.steam-run}/bin/steam-run ${test-binary}/myapp
''

# After testing, write proper package with autoPatchelfHook
```

## Building with steam-run for Complex Apps

For apps that resist autoPatchelf (DRM, integrity checks):

```nix
{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "myapp";
  version = "1.0.0";

  src = ./myapp-${version}.tar.gz;

  buildInputs = [ pkgs.steam-run ];

  buildPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    cp myapp $out/bin/

    # Wrap with steam-run
    wrapProgram $out/bin/myapp \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.steam-run ]}
  '';
}
```

## References

- [Steam FHS environment](https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/build-fhsenv-bubblewrap/)
- [buildFHSEnv](advanced-fhs-env.md) - Custom FHS environments

## See Also

- [troubleshooting-autoPatchelf](troubleshooting-autoPatchelf.md) - When steam-run isn't enough
- [advanced-fhs-env](advanced-fhs-env.md) - Custom FHS environments
- [dependencies](dependencies.md) - Finding the right dependencies
