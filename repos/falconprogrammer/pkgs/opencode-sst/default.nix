{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchzip,
  autoPatchelfHook,
  makeWrapper,
  nodejs,          # Provides Node.js runtime for opencode
  patchelf,        # Needed to fix dynamic linking of downloaded binaries
  writeShellScript,
  binutils,        # Additional tools for binary manipulation
  glibc,           # Standard C library for LD_LIBRARY_PATH
}: let
  # Maps Nix platform strings to opencode release architecture strings
  arch_string = platform:
    if platform == "x86_64-linux"
    then "linux-x64"
    else if platform == "aarch64-linux"
    then "linux-arm64"
    else if platform == "x86_64-darwin"
    then "darwin-x64"
    else if platform == "aarch64-darwin"
    then "darwin-arm64"
    else throw "Unsupported architecture: ${platform}";
in
  stdenv.mkDerivation rec {
    pname = "opencode";
    version = "1.0.15";

    src = fetchzip {
      url = "https://github.com/sst/opencode/releases/download/v${version}/opencode-${arch_string stdenv.hostPlatform.system}.zip";
      hash = "sha256-MZpvSXxH/BRL0gq36O0/NXVjbcKkIz5nscEuoLbwXbA=";
    };

    dontBuild = true;  # Pre-compiled binary, no build step needed
    dontStrip = true;  # Preserve symbols for compatibility

    # autoPatchelfHook: Fixes the main binary's dynamic linking
    # makeWrapper: Allows setting environment variables and PATH
    nativeBuildInputs = [autoPatchelfHook makeWrapper];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin $out/share/opencode
      
      # Move original binary to share directory (not in PATH)
      cp opencode $out/share/opencode/opencode-original
      chmod +x $out/share/opencode/opencode-original
      
      # OpenCode downloads TUI binaries at runtime that aren't NixOS-compatible.
      # This script patches them with the correct dynamic linker for NixOS.
      cat > $out/share/opencode/patch-opencode-cache.sh << 'EOF'
      #!/usr/bin/env bash
      set -e
      
      CACHE_DIR="''${XDG_CACHE_HOME:-\$HOME/.cache}/opencode"
      [[ -d "$CACHE_DIR" ]] || { echo "Cache dir not found: $CACHE_DIR"; exit 1; }
      
      echo "Patching OpenCode cache for NixOS..."
      patched=0
      
      find "$CACHE_DIR" -type f -executable | while read -r file; do
        if file "$file" | grep -q "dynamically linked"; then
          if ! readelf -l "$file" 2>/dev/null | grep -q "/nix/store.*ld-linux"; then
            echo "Patching: $file"
            patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} "$file" 2>/dev/null || true
            patched=$((patched + 1))
          fi
        fi
      done
      
      echo "Patched $patched files. OpenCode should work now!"
      EOF
      chmod +x $out/share/opencode/patch-opencode-cache.sh
      
      # Main opencode binary with automatic NixOS patching built-in
      cat > $out/bin/opencode << 'EOF'
      #!/bin/bash
      
      # Patches downloaded binaries to use NixOS dynamic linker
      patch_cache() {
        local cache_dir="''${XDG_CACHE_HOME:-\$HOME/.cache}/opencode"
        [[ -d "$cache_dir" ]] || return 0
        
        find "$cache_dir" -type f -executable 2>/dev/null | while read -r file; do
          if [[ -f "$file" ]]; then
            if file "$file" 2>/dev/null | grep -q "dynamically linked"; then
              if ! readelf -l "$file" 2>/dev/null | grep -q "/nix/store.*ld-linux"; then
                echo "Patching $file for NixOS..." >&2
                ${patchelf}/bin/patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} "$file" 2>/dev/null || true
              fi
            fi
          fi
        done
      }
      
      patch_cache
      exec ${placeholder "out"}/share/opencode/opencode-original "$@"
      EOF
      
      chmod +x $out/bin/opencode
      
      # Provide Node.js and patching tools in PATH for compatibility
      wrapProgram $out/bin/opencode \
        --prefix PATH : ${lib.makeBinPath [nodejs patchelf binutils]} \
        --set OPENCODE_NODEJS_PATH ${nodejs}/bin/node \
        --set LD_LIBRARY_PATH ${lib.makeLibraryPath [glibc]} \
        --set PATCHELF_PATH ${patchelf}/bin/patchelf
      
      runHook postInstall
    '';

    meta = {
      description = "AI coding agent, built for the terminal (NixOS-compatible)";
      homepage = "https://github.com/sst/opencode";
      license = lib.licenses.mit;
      mainProgram = "opencode";
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
      
      longDescription = ''
        OpenCode is an AI coding agent built for the terminal.
        
        NIXOS COMPATIBILITY: OpenCode downloads TUI binaries at runtime that use
        generic Linux dynamic linkers (/lib64/ld-linux-x86-64.so.2) which don't
        exist on NixOS. This package includes automatic patching to fix the
        dynamic linker paths for NixOS compatibility.
        
        USAGE OPTIONS:
        - Run 'opencode' - includes automatic NixOS patching
        - Or manually patch cache: $(nix-build -A opencode-sst)/share/opencode/patch-opencode-cache.sh
        
        The package provides Node.js ${nodejs.version} to avoid downloading issues.
      '';
    };
  }