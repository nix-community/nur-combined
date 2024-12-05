{
    stdenv, stdenvNoCC, lib, requireFile,
    version, gitRev ? null, src, patches ? [],
    supportsSDL2, includesUnfreeROMs,
    withX11 ? false, withSDL ? if supportsSDL2 then 2 else 1,
    withReadline ? true, readline ? null,
    enableUnfreeROMs ? false,
    libX11 ? null, SDL ? null, SDL2 ? null,
    buildExtensionROMs ? false, nasm ? null, pkgs ? null,
    appNames ? [],
    maintainers
}:
assert builtins.elem withSDL [false 1 2];
let
    withSDL1 = withSDL == 1;
    withSDL2 = withSDL == 2;
in
assert withSDL2 -> supportsSDL2;
assert withSDL2 -> SDL2 != null;
assert withSDL1 -> SDL != null;
assert withX11 -> libX11 != null;
assert withReadline -> readline != null;
assert enableUnfreeROMs -> includesUnfreeROMs;
assert buildExtensionROMs -> nasm != null && pkgs != null;
let
    src' = if !includesUnfreeROMs then src else requireFile rec {
        inherit (src) name url;
        hash = src.hashWithROMs;
        message = ''
            Unfortunately, we cannot download file ${name} automatically.
            This version of PCE includes unfree ROM images in its distribution.
            Please add${lib.optionalString (!enableUnfreeROMs) " either"} ${url}
            ${lib.optionalString (!enableUnfreeROMs) "or a pre-stripped version "}to the store with nix-prefetch-url.
            
            Alternatively, you may use a newer snapshot that has removed the
            unfree ROM images.
        '';
    };
    src'' = if !(includesUnfreeROMs && !enableUnfreeROMs) then src' else src.withoutROMs or (stdenvNoCC.mkDerivation {
        name = builtins.replaceStrings ["pce"] ["pce-without-unfree-roms"] src'.name;
        src = src';
        version_ = version;
        sourceRoot = ".";
        dontConfigure = true;
        dontBuild = true;
        preferLocalBuild = true;
        installPhase = ''
            runHook preInstall
            tar --sort=name \
                --mtime="@''${SOURCE_DATE_EPOCH}" \
                --owner=0 --group=0 --numeric-owner \
                --pax-option=exthdr.name=%d/PaxHeaders/%f,delete=atime,delete=ctime \
                --exclude=contrib/rom \
                -czf "$out" "pce-$version_"
            runHook postInstall
        '';
        outputHash = src.hashWithoutROMs;
    });
    pkgsm68kElf = import pkgs.path {
        inherit (pkgs) overlays;
        localSystem = pkgs.system;
        crossSystem = lib.systems.elaborate {
            config = "m68k-elf";
        };
    };
    macplus-cc = pkgsm68kElf.stdenv.cc;
in
stdenv.mkDerivation {
    pname = "pce" + lib.optionalString enableUnfreeROMs "-with-unfree-roms";
    inherit version;
    src = src'';
    # The config file for PCE has to point to the ROM extension file in $out/share/pce
    # to make certain features work. These patches allow the config file to refer to
    # $PCE_DIR_DATA in the 'path' setting, instead of having to update the config file
    # whenever the store path changes.
    patches = patches ++ [./patches/0001-Allow-referencing-PCE_DIR_DATA-in-config-files-inste.patch];
    postPatch = ''
        for file in src/arch/*/Makefile.inc; do
            substituteInPlace "$file" --replace-quiet '"s]PCE_DIR_DATA]$(datadir)]g"' '"s]PCE_DIR_DATA]\$$PCE_DIR_DATA/pce]g"'
        done
    '';
    configureFlags = [
        (lib.withFeature withX11 "x")
        (if supportsSDL2 then
            (lib.withFeatureAs (withSDL != null) "sdl" (toString withSDL))
        else
            (lib.withFeature withSDL1 "sdl")
        )
        (lib.enableFeature withReadline "readline")
        (lib.enableFeature buildExtensionROMs "ibmpc-rom")
        (lib.enableFeature buildExtensionROMs "macplus-rom")
    ];
    nativeBuildInputs = lib.optionals buildExtensionROMs [nasm macplus-cc];
    makeFlags = lib.optionals buildExtensionROMs [
        "MACX_CC=${macplus-cc.targetPrefix}cc"
        "MACX_LD=${macplus-cc.targetPrefix}ld"
        "MACX_OC=${macplus-cc.targetPrefix}objcopy"
    ];
    buildInputs =   lib.optional withX11 libX11
                ++  lib.optional withSDL1 SDL
                ++  lib.optional withSDL2 SDL2
                ++  lib.optional withReadline readline
    ;
    meta = {
        description = "PC Emulator";
        longDescription = "PCE is a collection of microcomputer emulators.";
        homepage = "http://www.hampa.ch/pce/";
        changelog = "http://git.hampa.ch/pce.git/shortlog/${if gitRev != null then gitRev else "refs/tags/pce-${version}"}";
        license = [lib.licenses.gpl2Only] ++ lib.optional enableUnfreeROMs lib.licenses.unfree;
        maintainers = [maintainers.Rhys-T];
        sourceProvenance = with lib.sourceTypes; [
            fromSource
        ] ++ lib.optionals (!buildExtensionROMs) [
            # A couple of the emulators include 'ROM extensions' that are prebuilt.
            # They're machine code for real CPUs that existed, but in the context of
            # running them in an emulator - and because they actually _need_ to run
            # in the emulator - 'bytecode' seems like the closest available option.
            # PCE includes the source code for these, and _can_ rebuild them. Set
            # `buildExtensionROMs = true` to enable this.
            binaryBytecode
        ];
    };
    
    passthru._Rhys-T.flakeApps = pceName: pce: builtins.listToAttrs (map (appName: lib.nameValuePair (builtins.replaceStrings ["pce"] [appName] pceName) {
        type = "app";
        program = lib.getExe' pce appName;
    }) appNames);
}
