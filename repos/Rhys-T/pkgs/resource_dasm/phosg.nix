{stdenv, lib, zlib, cmake, memorymappingHook ? {}.memorymappingHook, fmt, fetchFromGitHub, unstableGitUpdater, maintainers}: let
    needsMemorymapping = stdenv.hostPlatform.isDarwin && lib.versionOlder stdenv.hostPlatform.darwinMinVersion "10.13";
    needsFmt = stdenv.cc.isClang && stdenv.cc.libcxx != null && lib.versionOlder (lib.getVersion stdenv.cc.libcxx) "17";
in stdenv.mkDerivation rec {
    pname = "phosg";
    version = "0-unstable-2025-09-11";
    src = fetchFromGitHub {
        owner = "fuzziqersoftware";
        repo = "phosg";
        rev = "b2e0c12edb7e274a5e20c460f44eee44f49f57ef";
        hash = "sha256-9ciKqjq74IU1VuttykQ+J0k7jgdMrKz1Dc/bzOwKsjQ=";
    };
    postPatch = ''
        sed -Ei '/set\(CMAKE_OSX_ARCHITECTURES/ s@^@#@' CMakeLists.txt
    '' + lib.optionalString needsFmt ''
        shopt -s globstar
        for file in src/**/*.{cc,hh}; do
            substituteInPlace "$file" \
                --replace-quiet '#include <format>' '#include <fmt/format.h>' \
                --replace-quiet 'std::format' 'fmt::format' \
                --replace-quiet 'return format(' 'return fmt::format('
        done
        shopt -u globstar
    '';
    nativeBuildInputs = [cmake];
    buildInputs = [zlib] ++ lib.optionals needsMemorymapping [memorymappingHook];
    propagatedBuildInputs = lib.optionals needsFmt [fmt];
    env = lib.optionalAttrs needsFmt {
        NIX_LDFLAGS = "-lfmt";
    };
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
