{
    stdenv, stdenvNoCC, lib, requireFile,
    version, src, patches ? [],
    supportsSDL2, includesUnfreeROMs,
    withX11 ? false, withSDL ? if supportsSDL2 then 2 else 1,
    withReadline ? true,
    enableUnfreeROMs ? false,
    libX11 ? null, SDL ? null, SDL2 ? null,
    readline ? null,
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
    src'' = if !(includesUnfreeROMs && !enableUnfreeROMs) then src' else stdenvNoCC.mkDerivation {
        name = "romless-${src'.name}";
        src = src';
        version_ = version;
        sourceRoot = ".";
        configurePhase = "";
        buildPhase = "";
        preferLocalBuild = true;
        installPhase = ''
            tar --sort=name \
                --mtime="@''${SOURCE_DATE_EPOCH}" \
                --owner=0 --group=0 --numeric-owner \
                --pax-option=exthdr.name=%d/PaxHeaders/%f,delete=atime,delete=ctime \
                --exclude=contrib/rom \
                -czf "$out" "pce-$version_"
        '';
        outputHash = src.hashWithoutROMs;
    };
in
stdenv.mkDerivation {
    pname = "pce" + lib.optionalString enableUnfreeROMs "-with-unfree-roms";
    inherit version;
    src = src'';
    # The config file for PCE has to point to the ROM extension file in $out/share/pce
    # to make certain features work. These patches allow the config file to refer to
    # $PCE_DIR_DATA in the 'path' setting, instead of having to update the config file
    # whenever the store path changes.
    patches = patches ++ [./0001-Allow-referencing-PCE_DIR_DATA-in-config-files-inste.patch];
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
    ];
    buildInputs =   lib.optional withX11 libX11
                ++  lib.optional withSDL1 SDL
                ++  lib.optional withSDL2 SDL2
                ++  lib.optional withReadline readline
    ;
    meta = {
        description = "PC Emulator";
        longDescription = "PCE is a collection of microcomputer emulators.";
        license = [lib.licenses.gpl2Only] ++ lib.optional enableUnfreeROMs lib.licenses.unfree;
        maintainers = [maintainers.Rhys-T];
        sourceProvenance = with lib.sourceTypes; [
            fromSource
            # A couple of the emulators include 'ROM extensions' that are prebuilt.
            # They're machine code for real CPUs that existed, but in the context of
            # running them in an emulator - and because they actually _need_ to run
            # in the emulator - 'bytecode' seems like the closest available option.
            # PCE includes the source code for these, and _can_ rebuild them - I just
            # haven't gotten that part working under Nix yet.
            binaryBytecode
        ];
    };
}
