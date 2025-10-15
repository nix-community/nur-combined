{stdenv, lib, zlib, cmake, memorymappingHook ? {}.memorymappingHook, fuzziqersoftwareFmtPatchHook, phosg, netpbm, sdl3, fetchFromGitHub, useNetpbm?false, useSDL?true, ripgrep, makeBinaryWrapper, unstableGitUpdater, maintainers}: let
    needsMemorymapping = stdenv.hostPlatform.isDarwin && lib.versionOlder stdenv.hostPlatform.darwinMinVersion "10.13";
    needsFmt = fuzziqersoftwareFmtPatchHook.isNeeded;
in stdenv.mkDerivation rec {
    pname = "resource_dasm";
    version = "0-unstable-2025-10-12";
    src = fetchFromGitHub {
        owner = "fuzziqersoftware";
        repo = "resource_dasm";
        rev = "27bcc1e597718966da8a5bf371d276bf97b78d64";
        hash = "sha256-cjptjlvBv2fWcIb7LRhRzuYqyrDchhg3EQMmsXB2KZU=";
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
            This project contains multiple tools for reverse-engineering applications and games. Most of these tools are targeted at classic Mac OS (pre-OSX); a few are targeted at Nintendo GameCube games.
            
            The tools in this project are:
            * General tools
                * **resource_dasm**: A utility for working with classic Mac OS resources. It can read resources from classic Mac OS resource forks, AppleSingle/AppleDouble files, MacBinary files, Mohawk archives, or HIRF/RMF/IREZ/HSB archives, and convert the resources to modern formats and/or export them verbatim. It can also create and modify resource forks.
                * **libresource_file**: A library implementing most of resource_dasm's functionality.
                * **m68kdasm**: A 68K, PowerPC, x86, and SH-4 binary assembler and disassembler. m68kdasm can also disassemble some common executable formats.
                * **m68kexec**: A 68K, PowerPC, x86, and SH-4 CPU emulator and debugger.
                * **render_bits**: Renders raw data in a variety of color formats, including indexed formats. Useful for finding embedded images or understanding 2-dimensional arrays in unknown file formats.
                * **replace_clut**: Remaps an existing image from one indexed color space to another.
                * **assemble_images**: Combines multiple images into one. Useful for dealing with games that split large images into multiple smaller images due to format restrictions.
                * **dupe_finder**: Finds duplicate resources across multiple resource files.
            * Tools for specific formats
                * **render_text**: Renders text using bitmap fonts from FONT or NFNT resources.
                * **hypercard_dasm**: Disassembles HyperCard stacks and draws card images.
                * **decode_data**: Decodes some custom compression formats (see below).
                * **render_sprite**: Renders sprites from a variety of custom formats (see below).
                * **icon_unarchiver**: Exports icons from an Icon Archiver archive to .icns (see below).
                * **vrfsdump**: Extracts the contents of VRFS archives from Blobbo.
                * **gcmdump**: Extracts all files in a GCM file (GameCube disc image) or TGC file (embedded GameCube disc image).
                * **gcmasm**: Generates a GCM image from a directory tree.
                * **gvmdump**: Extracts all files in a GVM archive (from Phantasy Star Online) to the current directory, and converts the GVR textures to Windows BMP files. Also can decode individual GVR files outside of a GVM archive.
                * **rcfdump**: Extracts all files in a RCF archive (from The Simpsons: Hit and Run) to the current directory.
                * **smsdumpbanks**: Extracts the contents of JAudio instrument and waveform banks in AAF, BX, or BAA format (from Super Mario Sunshine, Luigi's Mansion, Pikmin, and other games). See "Using smssynth" for more information.
                * **smssynth**: Synthesizes and debugs music sequences in BMS format (from Super Mario Sunshine, Luigi's Mansion, Pikmin, and other games) or MIDI format (from classic Macintosh games). See "Using smssynth" for more information.
                * **modsynth**: Synthesizes and debugs music sequences in Protracker/Soundtracker MOD format.
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
        matchInfo = map (builtins.match "    \\* \\*\\*([^*]+)\\*\\*: (.*)") lines;
        actualMatches = builtins.filter (x: x != null && builtins.elemAt x 0 != "libresource_file") matchInfo;
        flakeApps = builtins.listToAttrs (map (appInfo: let
            name = builtins.elemAt appInfo 0;
            description = builtins.elemAt appInfo 1;
        in {
            inherit name;
            value = {
                type = "app";
                program = lib.getExe' resource_dasm name;
                meta = { inherit description; };
            };
        }) actualMatches);
    in flakeApps;
}
