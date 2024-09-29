{
    stdenv, lib, fetchurl, SDL_compat,
    romsFromMAME ? null, runCommand, python3,
    romsFromXML ? if romsFromMAME != null then runCommand "${romsFromMAME.pname}-pacman-roms.xml" {} ''
        "${lib.getExe romsFromMAME}" -listbrothers puckman \
            | tail -n +2 \
            | tr -s ' ' \
            | cut -d' ' -f2 \
            | xargs ${lib.getExe romsFromMAME} -listxml \
            > "$out"
    '' else null,
    maintainers
}: let
    romSourceName = romsFromMAME.name or (lib.removeSuffix ".xml" (romsFromXML.name or ""));
    romSourcePname = lib.getName romSourceName;
    romSourceVersion = lib.getVersion romSourceName;
    baseVersion = "0.3";
in stdenv.mkDerivation rec {
    suffix = lib.optionalString (romsFromXML != null) "-${romSourcePname}";
    pname = "pacifi3d${suffix}";
    version = baseVersion + lib.optionalString (romSourceVersion != "") "+${romSourceVersion}";
    # All-caps VERSION is what gets #define'd into the code.
    # Normally the top-level Makefile sets this, but we're bypassing it.
    # Also I want to be able to modify it to indicate my patches.
    VERSION = baseVersion + lib.optionalString (romsFromXML != null) " (${romSourceName} ROMs)";
    src = fetchurl {
        url = "http://pacifi3d.retrogames.com/pacifi3d/pacifi3d${baseVersion}-src.tgz";
        hash = "sha256-M9/XIHVXLFEV+SZAuwkSPKH+YZwdgQ1qFGBzWKjV0F8=";
    };
    whichPlatform = if stdenv.isDarwin then "macosx" else "linux";
    postPatch = ''
        sed -E -i.bak '
            s/\w+\s*=\s*gcc/#&/g
            ${lib.optionalString stdenv.isDarwin ''
                s/-mtune=G4//g
                s/-framework SDL/`sdl-config --libs`/g
                s@/Developer/Tools/CpMac@cp@g
            ''}
        ' "makefiles/Makefile.$whichPlatform"
        substituteInPlace src/Makefile.common --replace-fail '$(LD)' '$(CC)'
        substituteInPlace src/video.h --replace-fail 'void (*blitter)(void);' '// void (*blitter)(void);'
        for file in src/ghost.c src/pacman.c; do
            substituteInPlace "$file" --replace-fail 'enum {X, Y, Z} axes;' 'enum axes {X, Y, Z};'
        done
        substituteInPlace src/video.c --replace-fail 'char * color_prom' 'Uint8 * color_prom'
        substituteInPlace src/rom.c --replace-fail 'char* region' 'Uint8* region'
    '' + lib.optionalString (romsFromXML != null) ''
        ${lib.getExe python3} ${./mameXMLToC.py} ${romsFromXML} mame-roms.load.c mame-roms.list.c
        sed -E -i '
            /strcmp/,/\}/ {
                r/dev/fd/10
                d
            }
            /Supported sets are:/,/exit/ {
                /printf\("  / {
                    r/dev/fd/11
                    d
                }
            }
        ' src/rom.c 10< mame-roms.load.c 11< mame-roms.list.c
    '';
    sourceRoot = ".";
    buildInputs = [SDL_compat];
    makeFlags = [
        # Skip the top-level Makefile so we don't have to build the `package` target:
        "-f" "makefiles/Makefile.${whichPlatform}"
    ];
    buildFlags = ["common"] ++ lib.optional stdenv.isDarwin ".bundle";
    installPhase = ''
        mkdir -p "$out"/bin
        ${if stdenv.isDarwin then ''
            mkdir -p "$out"/Applications
            cp -r Pacifi3d.app "$out/Applications/Pacifi3d$suffix.app"
            ln -s "$out/Applications/Pacifi3d$suffix.app/Contents/MacOS/pacifi3d" "$out/bin/pacifi3d$suffix"
        '' else ''
            cp pacifi3d "$out/bin/pacifi3d$suffix"
        ''}
    '';
    meta = {
        description = "Pac-Man emulator in 3D" + lib.optionalString (romsFromXML != null) " (using ROMsets from ${romSourcePname})";
        longDescription = ''
            Pacifi3D is a proof-of-concept pacman emulator that replaces the original pacman sprites and tiles with OpenGL 3D graphics.
        '' + lib.optionalString (romsFromXML != null) ''
            
            This version has been patched to be compatible with ROMsets from ${romSourceName}.
            Note that some games might not be compatible with the 3D modes.
            (Ms. Pac-Man-based ROMs in particular use a different sprite mapping and confuse things.)
        '';
        homepage = "http://pacifi3d.retrogames.com/";
        platforms = with lib.platforms; linux ++ darwin;
        # No license explicitly specified. Credits seem to indicate some emulation code came from
        # MAME, which would have been under its old viral non-commercial license at the time.
        license = lib.licenses.unfree;
        maintainers = [maintainers.Rhys-T];
    };
}
