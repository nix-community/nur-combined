{stdenv, lib, zlib, cmake, memorymappingHook ? {}.memorymappingHook, fuzziqersoftwareFmtPatchHook, fetchFromGitHub, unstableGitUpdater, maintainers}: let
    needsMemorymapping = stdenv.hostPlatform.isDarwin && lib.versionOlder stdenv.hostPlatform.darwinMinVersion "10.13";
    needsFmt = fuzziqersoftwareFmtPatchHook.isNeeded;
in stdenv.mkDerivation rec {
    pname = "phosg";
    version = "0-unstable-2025-11-24";
    src = fetchFromGitHub {
        owner = "fuzziqersoftware";
        repo = "phosg";
        rev = "40831eeef971db1e100ae1ba68601f69fa581a70";
        hash = "sha256-j89a/qrEs1q4Usk1ZS9Sd8OOeJIRpqbmCyTxJKQTfMo=";
    };
    postPatch = ''
        substituteInPlace CMakeLists.txt \
            --replace-fail 'set(CMAKE_OSX_ARCHITECTURES' '#set(CMAKE_OSX_ARCHITECTURES' \
            --replace-fail 'target_link_libraries(phosg atomic)' 'target_link_libraries(phosg PRIVATE atomic)'
    '';
    nativeBuildInputs = [cmake] ++ lib.optionals needsMemorymapping [memorymappingHook] ++ lib.optionals needsFmt [fuzziqersoftwareFmtPatchHook];
    buildInputs = [zlib];
    meta = {
        description = "C++ helpers for some common tasks";
        longDescription = ''
            phosg is a basic C++ wrapper library around some common C routines.
            
            A short summary of its contents:
            - Byteswapping and encoding functions (base64, rot13)
            - Integer types with explicit endianness and transparent byteswapping
            - Directory listing, smart-pointer fopen and stat, file and path manipulation
            - Hash functions (fnv1a64, fnv1a32, sha1, sha256)
            - Basic image manipulation/drawing
            - JSON (de)serialization
            - Network helpers (IP address parsing/formatting, socket listen and connect functions)
            - Functions for getting random data from the OS
            - Process utilities (list processes, name <> PID mapping, subprocess execution)
            - Time conversions
            - 2D, 3D, and 4D vectors and basic vector math
            - KD-tree and LRU set data structures
            
            This project also includes a few simple executables:
            - **jsonformat**: Parses the input JSON and either minimizes it (with --compress) or reformats it for human readability (with --format).
            - **bindiff**: Shows the differing bytes between two binary files in a colored hex/ASCII view. This just does a direct comparison of the two files byte for byte; it doesn't run any e.g. edit-distance algorithm (yet).
            - **parse-data**: Parses the data format used by `phosg::parse_data_string` and outputs the result.
            - **phosg-png-conv**: Converts the input image (in any format that `phosg::Image` can load) to a PNG image.
        '';
        homepage = "https://github.com/fuzziqersoftware/phosg";
        license = lib.licenses.mit;
        broken = let
            memorymapping = builtins.elemAt memorymappingHook.propagatedBuildInputs 0;
        in needsMemorymapping && memorymapping.meta.broken;
        maintainers = [maintainers.Rhys-T];
    };
    passthru.needsFmt = needsFmt;
    passthru.updateScript = unstableGitUpdater { hardcodeZeroVersion = true; };
}
