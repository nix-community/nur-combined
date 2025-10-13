{stdenv, lib, zlib, cmake, memorymappingHook ? {}.memorymappingHook, fuzziqersoftwareFmtPatchHook, phosg, netpbm, sdl3, fetchFromGitHub, useNetpbm?false, useSDL?true, ripgrep, makeBinaryWrapper, unstableGitUpdater, maintainers}: let
    needsMemorymapping = stdenv.hostPlatform.isDarwin && lib.versionOlder stdenv.hostPlatform.darwinMinVersion "10.13";
    needsFmt = fuzziqersoftwareFmtPatchHook.isNeeded;
in stdenv.mkDerivation rec {
    pname = "resource_dasm";
    version = "0-unstable-2025-09-12";
    src = fetchFromGitHub {
        owner = "fuzziqersoftware";
        repo = "resource_dasm";
        rev = "2124a6372745c3e07a023af5067c47ab17f931f8";
        hash = "sha256-oLZRGsWHJBVKq+jCwafd5hiO3Y7xtuPEEGALZBKo5mE=";
    };
    nativeBuildInputs =
        [cmake]
        ++ lib.optionals useNetpbm [makeBinaryWrapper]
        ++ lib.optionals needsMemorymapping [memorymappingHook]
        ++ lib.optionals needsFmt [fuzziqersoftwareFmtPatchHook]
    ;
    buildInputs = [phosg zlib] ++ lib.optionals useSDL [sdl3];
    # The CMakeLists.txt file provided doesn't install all the executables. Patch it to include the rest:
    postPatch = ''
        allExes=($(sed -En '
            /.*add_executable\(([-_A-Za-z0-9]+).*/ {
                s//\1/
                p
            }
            /.*foreach\(ExecutableName IN ITEMS (.*)\).*$/ {
                s//\1/
                p
            }
        ' CMakeLists.txt))
        for exeToInstall in "''${allExes[@]}"; do
            installLine="install(TARGETS $exeToInstall DESTINATION bin)"
            ${lib.getExe ripgrep} -Fq "$installLine" CMakeLists.txt || echo "$installLine" >> CMakeLists.txt
        done
        # Fix invalid format strings:
        substituteInPlace src/Audio/MODSynthesizer.cc --replace-fail '{:-2}' '{:<2}'
        substituteInPlace src/Audio/smssynth.cc --replace-fail '{:-7}' '{:<7}'
    '';
    ${if useNetpbm then "postInstall" else null} = ''
        for file in "$out"/bin/*; do
            wrapProgram "$file" --prefix PATH : ${lib.makeBinPath [netpbm]}
        done
    '';
    meta = {
        description = "Classic Mac OS resource fork and application disassembler, with reverse-engineering tools for specific applications";
        longDescription = ''
            This project contains multiple tools for reverse-engineering classic Mac OS applications and games.
            
            The tools in this project are:
            * General tools
                * **resource_dasm**: A utility for working with classic Mac OS resources. It can read resources from classic Mac OS resource forks, AppleSingle/AppleDouble files, MacBinary files, Mohawk archives, or HIRF/RMF/IREZ/HSB archives, and convert the resources to modern formats and/or export them verbatim. It can also create and modify resource forks.
                * **libresource_file**: A library implementing most of resource_dasm's functionality.
                * **m68kdasm**: A 68K, PowerPC, x86, and SH-4 binary assembler and disassembler. m68kdasm can also disassemble some common executable formats.
                * **m68kexec**: A 68K, PowerPC, and x86 CPU emulator and debugger.
                * **render_bits**: Renders raw data in a variety of color formats, including indexed formats. Useful for finding embedded images or understanding 2-dimensional arrays in unknown file formats.
                * **replace_clut**: Remaps an existing image from one indexed color space to another.
                * **assemble_images**: Combines multiple images into one. Useful for dealing with games that split large images into multiple smaller images due to format restrictions.
                * **dupe_finder**: Finds duplicate resources across multiple resource files.
            * Tools for specific formats
                * **render_text**: Renders text using bitmap fonts from FONT or NFNT resources.
                * **hypercard_dasm**: Disassembles HyperCard stacks and draws card images.
                * **decode_data**: Decodes some custom compression formats (see README).
                * **render_sprite**: Renders sprites from a variety of custom formats (see README).
                * **icon_dearchiver**: Exports icons from an Icon Archiver archive to .icns (see README).
            * Game map generators
                * **blobbo_render**: Generates maps from Blobbo levels.
                * **bugs_bannis_render**: Generates maps from Bugs Bannis levels.
                * **ferazel_render**: Generates maps from Ferazel's Wand world files.
                * **gamma_zee_render**: Generates maps of Gamma Zee mazes.
                * **harry_render**: Generates maps from Harry the Handsome Executive world files.
                * **infotron_render**: Generates maps from Infotron levels files.
                * **lemmings_render**: Generates maps from Lemmings and Oh No! More Lemmings levels and graphics files.
                * **mshines_render**: Generates maps from Monkey Shines world files.
                * **realmz_dasm**: Generates maps from Realmz scenarios and disassembles the scenario scripts into readable assembly-like syntax.
        '';
        homepage = "https://github.com/fuzziqersoftware/resource_dasm";
        license = lib.licenses.mit;
        broken = let
            memorymapping = builtins.elemAt memorymappingHook.propagatedBuildInputs 0;
        in needsMemorymapping && memorymapping.meta.broken;
        maintainers = [maintainers.Rhys-T];
    };
    passthru.updateScript = unstableGitUpdater { hardcodeZeroVersion = true; };
    passthru._Rhys-T.flakeApps = rdName: resource_dasm: let
        lines = lib.splitString "\n" resource_dasm.meta.longDescription;
        matchInfo = map (builtins.match "    \\* \\*\\*([^*]+)\\*\\*.*") lines;
        actualMatches = builtins.filter (x: x != null) matchInfo;
        appNames = lib.lists.remove "libresource_file" (map (x: builtins.elemAt x 0) actualMatches) ++ ["vrfs_dump"];
        flakeApps = builtins.listToAttrs (map (name: {
            inherit name;
            value = {
                type = "app";
                program = lib.getExe' resource_dasm name;
            };
        }) appNames);
    in flakeApps;
}
