{
    stdenvNoCC, lib, buildDubPackage,
    fetchFromGitHub,
    allegro5, enet,
    makeBinaryWrapper, desktopToDarwinBundle, writeDarwinBundle,
    lix-game-assets, lix-game-music, includeMusic ? true,
    useHighResTitleScreen ? lix-game-assets.useHighResTitleScreen,
    convertImagesToTrueColor ? lix-game-assets.convertImagesToTrueColor,
    disableNativeImageLoader ? !convertImagesToTrueColor && stdenvNoCC.isDarwin
}: with import ./lib.nix { inherit stdenvNoCC lib enet; }; let
    allegro5' = if disableNativeImageLoader then allegro5.overrideAttrs (old: {
        cmakeFlags = (old.cmakeFlags or []) ++ ["-DWANT_NATIVE_IMAGE_LOADER=off"];
    }) else allegro5;
    desktopToDarwinBundleWithCustomPlistEntries = plistExtra: desktopToDarwinBundle.overrideAttrs (old: {
        propagatedBuildInputs = map (x: if x.name == "write-darwin-bundle" then writeDarwinBundle.override {
            lib = lib // {
                generators = lib.generators // {
                    toPlist = options: data: lib.generators.toPlist options (data // plistExtra);
                };
            };
        } else x) old.propagatedBuildInputs;
    });
    lix-game = buildDubPackage {
        pname = "lix-game";
        version = "0.10.26";
        src = fetchFromGitHub {
            owner = "SimonN";
            repo = "LixD";
            rev = "v${lix-game.version}";
            hash = "sha256-cDR/7GFkFPRH8HK5k4q3PMon2tW+eyCUL9qgNBtI2rU=";
        };
        dubLock = ./dub-lock.json;
        dubBuildType = "releaseXDG";
        nativeBuildInputs = lib.optionals stdenvNoCC.isDarwin [makeBinaryWrapper (desktopToDarwinBundleWithCustomPlistEntries {
            CFBundleIdentifier = "com.lixgame.Lix";
            LSApplicationCategoryType = "public.app-category.puzzle-games";
            NSHighResolutionCapable = true;
        })];
        buildInputs = [allegro5' enet];
        postPatch = ''
        sed -E -i '
            /libs-posix/ a\
            "allegro", "allegro_audio", "allegro_font",
            /libs-posix/,/\]/ s/-5//g
        ' dub.json
        substituteInPlace src/file/filename/fhs.d --replace-fail 'enum customReadOnlyDir = "";' "enum customReadOnlyDir = \"$out/share\";"
        '';
        
        # Ugly hack: I need to patch a few dub dependencies, and they're copied in by configurePhase, so I have to do it here.
        # Patch #1: Make derelict-enet use the full path to enet, so we don't have to handle it in a wrapper.
        # Patch #2 (Darwin only): Include the changes from <https://github.com/SiegeLord/DAllegro5/issues/56> to make the .app bundle work.
        postConfigure = patchEnetBindings + lib.optionalString stdenvNoCC.isDarwin ''
        for dir in "$DUB_HOME"/packages/allegro/*/allegro/; do
            patch -d "$dir" -p1 < ${./patches/DAllegro/fix-56-run-from-darwin-app-bundle.patch}
        done
        '';
        
        lixAssets = lix-game-assets.override { inherit lix-game useHighResTitleScreen convertImagesToTrueColor; };
        ${if includeMusic then "lixMusic" else null} = lix-game-music.override { inherit lix-game; };
        
        installPhase = ''
        runHook preInstall
        mkdir -p \
            "$out"/bin \
            "$out"/share/applications \
            "$out"/share/metainfo \
            "$out"/share/icons/hicolor/scalable/apps \
            "$out"/share/man/man6 \
            "$out"/share/doc \
            "$out"/share/licenses/lix
        cp bin/lix "$out"/bin
        '' + lib.optionalString stdenvNoCC.isDarwin (
            let
                libsToWrapWith = [
                    allegro5'   # The allegro5 derivation doesn't currently run fixDarwinDylibNames.
                                # Even if I use install_name_tool to put the full library paths into the executable,
                                # the libraries still don't have each other's full paths and can't load each other.
                ];
            in ''
            wrapProgram "$out"/bin/lix --prefix DYLD_LIBRARY_PATH ':' ${lib.escapeShellArg (lib.makeLibraryPath libsToWrapWith)}
            ''
        ) + (if includeMusic then ''
            mkdir -p "$out"/share/lix
            ln -s "$lixAssets"/* "$out"/share/lix/
            ln -s "$lixMusic" "$out"/share/lix/music
        '' else ''
            ln -s "$lixAssets" "$out"/share/lix
        '') + ''
        cp -r doc "$out"/share/doc/lix
        mv "$out"/share/doc/lix/lix.6 "$out"/share/man/man6
        mv "$out"/share/doc/lix/copying.txt "$out"/share/licenses/lix/COPYING
        cp data/desktop/com.lixgame.Lix.desktop "$out"/share/applications
        cp data/desktop/com.lixgame.Lix.metainfo.xml "$out"/share/metainfo
        cp data/images/lix_logo.svg "$out"/share/icons/hicolor/scalable/apps/com.lixgame.Lix.svg
        runHook postInstall
        '';
        meta = {
            description = "Lemmings-like game with puzzles, editor, multiplayer";
            longDescription = ''
                Lix is a puzzle game inspired by Lemmings (DMA Design, 1991). Lix is free and open source.
                
                Assign skills to guide the lix through over 850 singleplayer puzzles. Design your own levels with the included editor.
                
                Attack and defend in real-time multiplayer for 2 to 8 players: Who can save the most lix?
            '';
            homepage = "https://www.lixgame.com/";
            changelog = "https://github.com/SimonN/LixD/releases/tag/v${lix-game.version}";
            license = lib.unique (
                [lib.licenses.cc0] ++ 
                lib.toList (lix-game-assets.meta.license or []) ++ 
                lib.optionals includeMusic (lib.toList (lix-game-music.license or []))
            );
            mainProgram = "lix";
        };
    };
in lix-game
