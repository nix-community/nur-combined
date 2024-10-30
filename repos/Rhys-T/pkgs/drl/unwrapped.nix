{ stdenv, lib, fetchFromGitHub, writeText, lua5_1, SDL2, SDL2_image, SDL2_mixer, SDL2_ttf, ncurses, darwin, fpc, maintainers }: let
    libExt = if stdenv.isDarwin then "dylib" else "so";
    version = "0.9.9.8a";
    gitShortRev = "97f1c51";
    rev = builtins.replaceStrings ["."] ["_"] version;
    shortVersion = lib.concatStrings (builtins.filter (x: builtins.match "[0-9]+" x != null) (builtins.splitVersion version));
    src = fetchFromGitHub {
        owner = "chaosforgeorg";
        repo = "doomrl";
        inherit rev;
        hash = "sha256-5FwaBuMFrz5dOxhHsJZLmL/PkwhXgW5XpVKDWoiVuWk=";
    };
    fpcvalkyrie = fetchFromGitHub {
        owner = "chaosforgeorg";
        repo = "fpcvalkyrie";
        rev = "0_9_0a";
        hash = "sha256-R/FgbmT7pvw9Qn0a7uR/Hw4pEQ2mArZY6sqXShQWU1Q=";
    };
in stdenv.mkDerivation rec {
    pname = "drl-unwrapped";
    inherit version gitShortRev;
    inherit src fpcvalkyrie;
    postUnpack = ''
        cp -r "$fpcvalkyrie" fpcvalkyrie
        chmod -R u+rwX fpcvalkyrie
        export FPCVALKYRIE_ROOT="$PWD/fpcvalkyrie/"
    '';
    nativeBuildInputs = [lua5_1 fpc];
    buildInputs = [lua5_1 SDL2 SDL2_image SDL2_mixer SDL2_ttf ncurses] ++ lib.optionals stdenv.isDarwin [darwin.apple_sdk.Libsystem];
    env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-unused-command-line-argument";
    env.NIX_LDFLAGS = lib.optionalString stdenv.isDarwin (lib.concatMapStringsSep " " (f: "-F${f}/Library/Frameworks") (with darwin.apple_sdk.frameworks; [CoreFoundation Cocoa]));
    env.NIX_DEBUG = 7;
    postPatch = ''
        sed -i '
            /fpc_params =/ a\
                "-dLUA_DYNAMIC",
            /macosx_version_min/ d
            /OSX_APP_BUNDLE/ d
        ' makefile.lua
        substituteInPlace makefile.lua --replace-fail 'make.gitrevision()' "(function()
            local revision = '$gitShortRev'
            return {
                full = revision,
                working = tonumber(revision, 16),
                current = tonumber(revision, 16),
                mod = mod,
            }
        end)()"
        substituteInPlace "$FPCVALKYRIE_ROOT"/libs/vlualibrary.pas \
            --replace-fail 'lua5.1.${libExt}' '${lib.getLib lua5_1}/lib/liblua.5.1.${libExt}'
        substituteInPlace "$FPCVALKYRIE_ROOT"/libs/vsdl2library.pas \
            --replace-fail '${if stdenv.isDarwin then "SDL2.framework/SDL2" else "libSDL2-2.0.so.0"}' '${lib.getLib SDL2}/lib/libSDL2.${libExt}' \
            --replace-fail '{$linklib SDLmain}' '{.$linklib SDL2main}' \
            --replace-fail '{$linkframework SDL}' '{$linklib SDL2}' \
            --replace-fail '{$PASCALMAINNAME SDL_main}' '{.$PASCALMAINNAME SDL_main}'
        substituteInPlace "$FPCVALKYRIE_ROOT"/libs/vsdl2imagelibrary.pas \
            --replace-fail '${if stdenv.isDarwin then "SDL2_image.framework/SDL_image" else "libSDL2_image-2.0.so.0"}' '${lib.getLib SDL2_image}/lib/libSDL2_image.${libExt}'
        substituteInPlace "$FPCVALKYRIE_ROOT"/libs/vsdl2mixerlibrary.pas \
            --replace-fail '${if stdenv.isDarwin then "SDL2_mixer.framework/SDL2_mixer" else "libSDL2_mixer-2.0.so.0"}' '${lib.getLib SDL2_mixer}/lib/libSDL2_mixer.${libExt}'
        substituteInPlace "$FPCVALKYRIE_ROOT"/libs/vsdl2ttflibrary.pas \
            --replace-fail '${if stdenv.isDarwin then "SDL2_ttf.framework/SDL2_ttf" else "libSDL2_ttf-2.0.so.0"}' '${lib.getLib SDL2_ttf}/lib/libSDL2_ttf.${libExt}'
    '' + lib.optionalString stdenv.isDarwin ''
        sed -E -i '
            /glExtLoader/ {
                /GetSymbolExt\s*:=/ s/glExtLoader/GetSymbol/
                /GetSymbolExt\s*:=/! d
            }
        ' "$FPCVALKYRIE_ROOT"/libs/vgl3library.pas
    '';
    configurePhase = ''
        runHook preConfigure
        cp ${writeText "config.lua" ''
            OS = "${if stdenv.isDarwin then "MACOSX" else "LINUX"}"
        ''} config.lua
        runHook postConfigure
    '';
    buildPhase = ''
        runHook preBuild
        mkdir tmp
        lua makefile.lua
        runHook postBuild
    '';
    installPhase = ''
        runHook preInstall
        mkdir -p "$out"/share/drl
        cp bin/drl "$out"/share/drl/drl
        for file in \
            backup \
            mortem \
            screenshot \
            modules \
            config.lua \
            colors.lua \
            sound.lua \
            soundhq.lua \
            music.lua \
            musichq.lua \
            manual.txt \
            version.txt \
            version_api.txt \
            drl.wad \
            core.wad \
        ; do
            cp -r bin/"$file" "$out"/share/drl/"$file"
        done
        runHook postInstall
    '';
    meta = {
        description = "Roguelike game based on the FPS Doom";
        longDescription = ''
            DRL (D**m, the Roguelike) is a fast and furious coffee-break Roguelike game, that is heavily inspired by the popular FPS game Doom by ID Software.
        '';
        homepage = "https://drl.chaosforge.org/";
        licenses = with lib.licenses; [
            # Code
            gpl2Only
            # Artwork
            # Music (according to <https://simonvolpert.com/drla/>)
            cc-by-sa-40
        ];
        badPlatforms = with lib.platforms; linux ++ aarch64;
        maintainers = [maintainers.Rhys-T];
    };
}
