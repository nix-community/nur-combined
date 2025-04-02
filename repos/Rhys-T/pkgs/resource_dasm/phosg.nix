{stdenv, lib, zlib, cmake, memorymappingHook ? {}.memorymappingHook, fetchFromGitHub, unstableGitUpdater, maintainers}: let
    needsMemorymapping = stdenv.hostPlatform.isDarwin && lib.versionOlder stdenv.hostPlatform.darwinMinVersion "10.13";
in stdenv.mkDerivation rec {
    pname = "phosg";
    version = "0-unstable-2025-03-31";
    src = fetchFromGitHub {
        owner = "fuzziqersoftware";
        repo = pname;
        rev = "3009f5f50d5b8743bb99d93292aee63f3f3d3f4e";
        hash = "sha256-8vJSvO+fsP4gyL0qMJ2cwgzcKIV09IVIeA4uZM9x+Rs=";
    };
    postPatch = ''
        sed -Ei '/set\(CMAKE_OSX_ARCHITECTURES/ s@^@#@' CMakeLists.txt
    '';
    nativeBuildInputs = [cmake];
    buildInputs = [zlib] ++ lib.optionals needsMemorymapping [memorymappingHook];
    meta = {
        description = "C++ helpers for some common tasks";
        longDescription = ''
            Phosg is a basic C++ wrapper library around some common C routines.
            
            A short summary of its contents:
            - Byteswapping and encoding functions (base64, rot13)
            - Directory listing, smart-pointer fopen and stat, file and path manipulation
            - Hash functions (fnv1a64, sha1, sha256, md5)
            - Basic image manipulation/drawing
            - JSON (de)serialization
            - Network helpers (IP address parsing/formatting, listen/connect sockets)
            - OS random data sources
            - Process utilities (list processes, name <> PID mapping, subprocess execution)
            - Time conversions
            - std::string helpers like printf, split, time/size formatting, etc.
            - 2D, 3D, 4D vectors and basic vector math
            - KD-tree and LRU set data structures
            
            Phosg also includes an executable (jsonformat) that reformats JSON.
        '';
        homepage = "https://github.com/fuzziqersoftware/phosg";
        license = lib.licenses.mit;
        broken = let
            memorymapping = builtins.elemAt memorymappingHook.propagatedBuildInputs 0;
        in needsMemorymapping && memorymapping.meta.broken;
        maintainers = [maintainers.Rhys-T];
    };
    passthru.updateScript = unstableGitUpdater { hardcodeZeroVersion = true; };
}
