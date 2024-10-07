{
    stdenvNoCC, lib, buildDubPackage,
    fetchFromGitHub,
    allegro5, enet,
    makeBinaryWrapper, desktopToDarwinBundle, writeDarwinBundle,
    disableNativeImageLoader,
    pkg-config,
    common
}: let
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
        pname = "${common.pname}-unwrapped";
        inherit (common) version src;
        dubLock = ./dub-lock.json;
        dubBuildType = "releaseXDG";
        nativeBuildInputs = [pkg-config] ++ lib.optionals stdenvNoCC.isDarwin [makeBinaryWrapper (desktopToDarwinBundleWithCustomPlistEntries {
            CFBundleIdentifier = "com.lixgame.Lix";
            LSApplicationCategoryType = "public.app-category.puzzle-games";
            NSHighResolutionCapable = true;
        })];
        buildInputs = [allegro5' enet];
        
        # Ugly hack: I need to patch a few dub dependencies, and they're copied in by configurePhase, so I have to do it here.
        # Patch #1: Make derelict-enet use the full path to enet, so we don't have to handle it in a wrapper.
        # Patch #2 (Darwin only): Include the changes from <https://github.com/SiegeLord/DAllegro5/issues/56> to make the .app bundle work.
        postConfigure = common.patchEnetBindings + lib.optionalString stdenvNoCC.isDarwin ''
        for dir in "$DUB_HOME"/packages/allegro/*/allegro/; do
            patch -d "$dir" -p1 < ${./patches/DAllegro/fix-56-run-from-darwin-app-bundle.patch}
        done
        '';
        
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
        ) + ''
        cp -r doc "$out"/share/doc/lix
        mv "$out"/share/doc/lix/lix.6 "$out"/share/man/man6
        mv "$out"/share/doc/lix/copying.txt "$out"/share/licenses/lix/COPYING
        cp data/desktop/com.lixgame.Lix.desktop "$out"/share/applications
        cp data/desktop/com.lixgame.Lix.metainfo.xml "$out"/share/metainfo
        cp data/images/lix_logo.svg "$out"/share/icons/hicolor/scalable/apps/com.lixgame.Lix.svg
        runHook postInstall
        '';
        meta = common.meta // {
            description = "${common.meta.description} (game engine only)";
            license = lib.licenses.cc0;
            mainProgram = "lix";
            # derelict-enet currently only knows how to find the enet library for Windows, macOS, and Linux.
            # It could probably be patched to work on *BSD if needed.
            platforms = with lib.platforms; linux ++ darwin;
        };
    };
in lix-game
