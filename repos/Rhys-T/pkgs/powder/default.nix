{ stdenv, lib, SDL_compat, fetchurl, maintainers }: let maintainers' = maintainers; in stdenv.mkDerivation rec {
    pname = "powder";
    version = "118";
    src = fetchurl {
        url = "http://zincland.com/powder/release/${pname}${version}_src.tar.gz";
        hash = "sha256-ToEvOXLH3R/yQDVX0c2JGphHD1nM8JvAPOedr9EY89c=";
    };
    debian = fetchurl {
        url = "mirror://debian/pool/non-free/${builtins.substring 0 1 pname}/${pname}/${pname}_${version}+dfsg1-4.debian.tar.xz";
        hash = "sha256-ugBPgfJP8LbyCi10CI0Eisx0KJfwg5l0cCXWN6vikfk=";
    };
    buildInputs = [SDL_compat];
    env.CXXFLAGS = "-O3 -DCHANGE_WORK_DIRECTORY -Wno-error=${lib.optionalString stdenv.cc.isClang "c++11-"}narrowing";
    postUnpack = ''
        unpackFile "$debian"
    '';
    postPatch = ''
        substituteInPlace ../debian/powder.desktop --replace-fail '/usr/games/powder' "$out/bin/powder"
    '' + lib.optionalString stdenv.hostPlatform.isDarwin ''
        substituteInPlace port/mac/Makefile --replace-fail 'SDLMain.o' '''
        substituteInPlace make/makerules.OSX \
            --replace-fail '-I/Library/Frameworks/SDL.framework/Headers' '$(shell sdl-config --cflags)' \
            --replace-fail '-framework SDL' '$(shell sdl-config --libs)' \
            --replace-fail '-mmacosx-version-min=10.5' '''
    '';
    buildPhase = ''
        runHook preBuild
        for supportDir in bmp2c encyclopedia2c enummaker map2c txt2c tile2c; do
            make -C support/"$supportDir" clean
            make -C support/"$supportDir"
        done
        make -C port/${if stdenv.hostPlatform.isDarwin then "mac" else "linux"} clean
        make -C port/${if stdenv.hostPlatform.isDarwin then "mac" else "linux"} premake
        make -C port/${if stdenv.hostPlatform.isDarwin then "mac" else "linux"}
    '' + lib.optionalString stdenv.hostPlatform.isDarwin ''
        # Build app bundle
        pushd port/mac
        sed -E '/Building a DMG/ Q' builddmg.sh | bash
        popd
    '' + ''
        runHook postBuild
    '';
    installPhase = ''
        runHook preInstall
        ${if stdenv.hostPlatform.isDarwin then ''
            mkdir -p "$out"/Applications
            cp -r port/mac/app/*.app "$out"/Applications/
            mkdir -p "$out"/bin
            ln -s "$out"/Applications/*.app/Contents/MacOS/* "$out"/bin/powder
        '' else ''
            install -Dm755 powder "$out"/bin/powder
        ''}
        install -Dm755 ../debian/powder.desktop "$out"/share/applications/powder.desktop
        install -Dm644 ../debian/powder.xpm "$out"/share/icons/hicolor/32x32/apps/powder.xpm
        install -Dm644 ../debian/powder.6 "$out"/share/man/man6/powder.6
        install -Dm644 -t "$out"/share/docs/powder README.TXT CREDITS.TXT
        # TODO Are these right? See license notes below
        install -Dm644 LICENSE.TXT "$out"/share/licenses/powder/LICENSE
        install -Dm644 COPYING "$out"/share/licenses/powder/source/COPYING
        runHook postInstall
    '';
    meta = {
        description = "Graphical roguelike, originally designed for the Game Boy Advance";
        longDescription = ''
            This is a roguelike originally developed specifically for the Gameboy
            Advance (GBA). It is not a port of an existing roguelike as the controls
            of the GBA are very different from the traditional keyboard, and the screen
            imposes some additional limitations. It is built around replayability and
            long term ergonomics, not short term learning. It uses actual graphic tiles
            (16x16) rather than the traditional characters.
        '';
        homepage = "http://www.zincland.com/powder/";
        license = with lib.licenses; [
            # Main source code:
            # Note: COPYING says CC Sampling+, but LICENSE.TXT seems to say something different.
            # The POWDER website also says CC Sampling+. For now, I'm listing both.
            # I _think_ LICENSE.TXT applies to the official binaries, and COPYING is for the
            # source code? Not sure what that means for binaries _you_ build from that code…
            {
                shortName = "POWDER";
                fullName = "POWDER license";
                url = "https://salsa.debian.org/games-team/powder/-/blob/master/debian/copyright?ref_type=heads#L19-81";
                free = false;
            }
            {
                shortName = "CC-Sampling-Plus-1.0";
                fullName = "Creative Commons Sampling Plus 1.0";
                url = "https://creativecommons.org/licenses/sampling+/1.0/";
                free = false;
            }
            
            # mt19937ar.c:
            bsd3
            # Slight variant? Condition 3 says "The names of its contributors may not" instead
            # of "Neither the name of the copyright holder nor the names of its contributors may".
            # Maybe an older version or something?
            
            # Most tilesets:
            cc-by-30
            
            # adambolt tileset:
            {
                shortName = "adambolt";
                fullName = "Adam Bolt tileset license";
                url = "https://angband.live/forums/forum/angband/vanilla/44-graphical-ideas-for-bands/page2?postcount=16#post11055";
                free = true;
            }
            
            # Misc:
            # classic and nethack tilesets are under informal 'use it however you want' licenses.
            # A few source files are under unknown licenses. Some of them say 'BSD license', but
            # don't say which one. Others from the same author are under a 'CLIFE license'. They
            # both refer to 'LICENCE.TXT' (with that spelling), which is not present in POWDER.
            # I haven't been able to track down upstream sources to clarify these, but at least
            # the BSD one should qualify as 'free'. I'm counting them both here for now and
            # hoping for the best.
            free
            
            # ibsongrey tileset:
            publicDomain
            
            # There's also some Apache-2.0 code in there, but only in the Android port.
        ];
        mainProgram = "powder";
        maintainers = [maintainers'.Rhys-T];
    };
}
