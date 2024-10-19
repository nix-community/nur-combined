{
    stdenv, lib, buildDubPackage,
    fetchFromGitHub,
    allegro5, enet,
    makeBinaryWrapper, desktopToDarwinBundle, writeDarwinBundle,
    disableNativeImageLoader,
    pkg-config,
    overrideSDK, fetchpatch,
    common
}: let
    inherit (stdenv) isDarwin;
    allegro5' = if disableNativeImageLoader == "CIImage" then (allegro5.override {
        stdenv = overrideSDK stdenv {
            darwinMinVersion = "10.14";
            darwinSdkVersion = "11.0";
        };
    }).overrideAttrs (old: {
        # src = fetchFromGitHub {
        #     owner = "pedro-w";
        #     repo = "allegro5";
        #     rev = "c196fe292eb28d20e2d21d639651bbafc78373f2";
        #     hash = "sha256-PyAQN1CfR3PfG2lUZIYc+eCcULHSbWvMWKQgonS7xHo=";
        # };
        patches = (old.patches or []) ++ [
            (fetchpatch {
                url = "https://github.com/pedro-w/allegro5/commit/c196fe292eb28d20e2d21d639651bbafc78373f2.patch";
                hash = "sha256-lwAfRu10EPxUwsqpyd7j4Ic01A0UvFMhzML8qpWrFIE=";
            })
        ];
    }) else if disableNativeImageLoader then allegro5.overrideAttrs (old: {
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
        nativeBuildInputs = [pkg-config] ++ lib.optionals isDarwin [makeBinaryWrapper (desktopToDarwinBundleWithCustomPlistEntries {
            CFBundleIdentifier = "com.lixgame.Lix";
            LSApplicationCategoryType = "public.app-category.puzzle-games";
            NSHighResolutionCapable = true;
        })];
        buildInputs = [allegro5' enet];
        
        ${if disableNativeImageLoader == "CIImage" then "postPatch" else null} = ''
            substituteInPlace src/basics/alleg5.d --replace-fail '"Allegro %d.%d.%d"' '"Allegro %d.%d.%d (with pedro-w CIImage loader)"'
        '';
        
        # Ugly hack: I need to patch a few dub dependencies, and they're copied in by configurePhase, so I have to do it here.
        # Patch #1: Make derelict-enet use the full path to enet, so we don't have to handle it in a wrapper.
        # Patch #2 (Darwin only): Include the changes from <https://github.com/SiegeLord/DAllegro5/issues/56> to make the .app bundle work.
        postConfigure = common.patchEnetBindings + lib.optionalString isDarwin ''
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
        '' + lib.optionalString isDarwin (
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
