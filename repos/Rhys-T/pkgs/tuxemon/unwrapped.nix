{
    python3Packages,
    fetchFromGitHub, fetchPypi, fetchurl,
    lib, stdenv,
    version, rev ? "v${version}", hash?null,
    libShake ? null, withLibShake ? true,
    desktopToDarwinBundle,
    data, attachPkgs, pkgs,
    SDL2_classic_image ? null, SDL2_classic_mixer_2_0 ? null, SDL2_classic_ttf ? null,
    _pos, gitUpdater, unstableGitUpdater, symlinkJoin, writeShellApplication,
    maintainers
}: let
    inherit (stdenv) hostPlatform;
    python3PackagesOrig = python3Packages;
in let
    python3Packages = (python3PackagesOrig.python.override {
        packageOverrides = pself: psuper: {
            pyglet = pself.callPackage ./fix-pyglet.nix { pyglet' = psuper.pyglet; };
            pysdl3 = if lib.versionAtLeast pkgs.sdl3.version "3.2.26" then psuper.pysdl3.overridePythonAttrs (old: {
                disabledTests = (old.disabledTests or []) ++ ["test_SDL_GetSetClipRect"];
            }) else psuper.pysdl3;
            # Backport fix from <https://github.com/NixOS/nixpkgs/pull/405640>
            pygame-ce = let
                inherit (psuper) pygame-ce;
                pygame-ce-args = lib.functionArgs pygame-ce.override;
            in if pygame-ce-args?SDL2_classic && pygame-ce-args?SDL2_image then pygame-ce.override {
                SDL2_image = SDL2_classic_image;
                SDL2_mixer = SDL2_classic_mixer_2_0;
                SDL2_ttf = SDL2_classic_ttf;
            } else pygame-ce;
        };
    }).pkgs;
    neteria = python3Packages.buildPythonPackage rec {
        pname = "neteria";
        version = "1.0.2";
        src = fetchPypi {
            inherit pname version;
            hash = "sha256-Z/uCYGquDLEU1NsKKJ/QqE8xJl5tgT+i0HYbBVCP9Ks=";
        };
        postPatch = ''
            substituteInPlace neteria/core.py --replace-fail 'is not 0' '!= 0'
        '';
        dependencies = with python3Packages; [rsa];
        pyproject = true;
        build-system = with python3Packages; [setuptools];
    };
    pyscroll = python3Packages.buildPythonPackage rec {
        pname = "pyscroll";
        version = "2.31";
        src = fetchPypi {
            inherit pname version;
            hash = "sha256-GQIFGyCEN5/I22mfCgDSbV0g5o+Nw8RT316vOSsqbHA=";
        };
        dependencies = with python3Packages; [pygame-ce];
        pyproject = true;
        build-system = with python3Packages; [setuptools];
    };
    pygame_menu_ce = python3Packages.buildPythonPackage rec {
        pname = "pygame_menu_ce";
        version = "4.5.4";
        src = fetchPypi {
            inherit pname version;
            hash = "sha256-9Y85GHJjBLoE1mt6k+PbRt2J0jr0aPOfWmjL3QjJPhI=";
        };
        dependencies = with python3Packages; [pygame-ce pyperclip typing-extensions];
        pyproject = true;
        build-system = with python3Packages; [setuptools];
    };
    usingPathlib = lib.versionAtLeast version "0.4.34-unstable-2025-05-29";
    has3179 = lib.versionAtLeast version "0.4.34-unstable-2025-10-11";
    # Work around lack of NixOS/nixpkgs#386513 in Nixpkgs <= 24.11
    hasEnabledTestPaths = (python3Packages.pytestCheckHook.tests or {})?enabledTestPaths;
    tuxemon = python3Packages.buildPythonApplication {
        pname = "tuxemon";
        inherit version;
        env = lib.optionalAttrs (lib.hasInfix "-unstable-" version) {
            SETUPTOOLS_SCM_PRETEND_VERSION = "${builtins.replaceStrings ["-unstable-" "-"] [".1.dev" ""] version}+g${builtins.substring 0 8 rev}";
        };
        src = fetchFromGitHub {
            owner = "Tuxemon";
            repo = "Tuxemon";
            inherit rev;
            ${if hash != null then "hash" else null} = hash;
        };
        pyproject = true;
        pythonRelaxDeps = true;
        pythonRemoveDeps = ["pygame_menu" "pygame-menu"] ++ lib.optional (lib.versionOlder version "0.4.34-unstable-2023-03-03") ["pygame"];
        nativeBuildInputs = [python3Packages.pythonRelaxDepsHook] ++ lib.optional hostPlatform.isDarwin desktopToDarwinBundle;
        nativeCheckInputs = with python3Packages; [pytestCheckHook];
        build-system = with python3Packages; [
            setuptools
            setuptools-scm
        ];
        dependencies = with python3Packages; [
            babel
            cbor
            neteria
            pillow
            pygame-ce
            pyscroll
            (pytmx.override { pygame = pygame-ce; })
            requests
            natsort
            pyyaml
            prompt-toolkit
            pygame_menu_ce
            pydantic
        ];
        inherit data;
        postPatch = ''
            substituteInPlace tuxemon/platform/__init__.py \
                --replace-fail '"/usr/share/tuxemon/"' 'os.path.join(os.getenv("NIX_TUXEMON_DIR"), "")'
            sed -Ei '
                s@import logging@&, sys@
                /mods_folder =/ {
                    ${if usingPathlib then
                        ''s@\(LIBDIR\.parent / "mods"\)@(Path(__import__("os").getenv("NIX_TUXEMON_DIR")) / "mods")@''
                    else
                        ''s@os.path.join\(LIBDIR, "\.\.", "mods"\)@os.path.join(os.getenv("NIX_TUXEMON_DIR"), "mods")@''
                    }
                }
            ' tuxemon/constants/paths.py
        '' + lib.optionalString withLibShake ''
            sed -Ei 's@locations = \[.*\]@locations = ["${lib.getLib libShake}/lib/libShake${hostPlatform.extensions.sharedLibrary}"]@' tuxemon/rumble/__init__.py
        '' + lib.optionalString (lib.versionAtLeast version "0.4.34-unstable-2025-03-14") ''
                    substituteInPlace tuxemon/${if has3179 then "database/utils" else "db"}.py --replace-fail \
            '        return DatabaseConfig(**data)' \
            '        config = DatabaseConfig(**data);
                    config.mod_base_path = ${if usingPathlib then 
                        ''Path(config_path).parent.parent / config.mod_base_path''
                    else
                        ''os.path.join(os.path.dirname(os.path.dirname(config_path)), config.mod_base_path)''
                    }
                    return config'${if has3179 then '' \
                        --replace-fail 'def load_config' $'from pathlib import Path\ndef load_config'
                    '' else ""}
        '';
        makeWrapperArgs = ["--set-default NIX_TUXEMON_DIR $out/share/tuxemon"];
        postInstall = ''
            mkdir -p "$out"/share/tuxemon/mods
            ln -s "$data"/share/tuxemon/mods/* "$out"/share/tuxemon/mods/
            install -Dm755 run_tuxemon.py "$out"/bin/tuxemon # replaces default tuxemon command - has more CLI options
            install -Dm755 buildconfig/flatpak/org.tuxemon.Tuxemon.desktop "$out"/share/applications/org.tuxemon.Tuxemon.desktop
            substituteInPlace "$out"/share/applications/org.tuxemon.Tuxemon.desktop --replace-fail 'Exec=org.tuxemon.Tuxemon' 'Exec=tuxemon'
            install -Dm755 buildconfig/flatpak/org.tuxemon.Tuxemon.appdata.xml "$out"/share/metainfo/org.tuxemon.Tuxemon.appdata.xml
            install -Dm644 mods/tuxemon/gfx/icon.png "$out"/share/icons/hicolor/64x64/apps/org.tuxemon.Tuxemon.png
            install -Dm644 mods/tuxemon/gfx/icon_128.png "$out"/share/icons/hicolor/128x128/apps/org.tuxemon.Tuxemon.png
            install -Dm644 mods/tuxemon/gfx/icon_32.png "$out"/share/icons/hicolor/32x32/apps/org.tuxemon.Tuxemon.png
        '';
        preCheck = ''
            export HOME="$(mktemp -d)" NIX_TUXEMON_DIR="$PWD" SDL_VIDEODRIVER=dummy
        '';
        ${if hasEnabledTestPaths then "enabledTestPaths" else "pytestFlagsArray"} = ["tests/"];
        disabledTests = [
            "test_blit_alpha" # AssertionError: 128 != 127 - probably just an artifact of the dummy video driver(?)
            "test_constrain_width_single_line" # fails to load Arial font, but only on aarch64-linux for some reason
            "test_draw_text_right_justify" # ditto
        ];
        dontStrip = true;
        meta = {
            description = "Open source monster-fighting RPG";
            longDescription = ''
                Tuxemon is a free, open source monster-fighting RPG. It's in constant development and improving all the time! Contributors of all skill levels are welcome to join.
                
                Features:
                * Game data is all json, easy to modify and extend
                * Game maps are created using the Tiled Map Editor
                * Simple game script to write the story
                * Dialogs, interactions on map, npc scripting
                * Localized in several languages
                * Seamless keyboard, mouse, and gamepad input
                * Animated maps
                * Lots of documentation
                * Python code can be modified without a compiler
                * CLI interface for live game debugging
                * Runs on Windows, Linux, OS X, and some support on Android
                * 183 monsters with sprites
                * 98 techniques to use in battle
                * 221 NPC sprites
                * 18 items
            '';
            homepage = "https://tuxemon.org/";
            mainProgram = "tuxemon";
            license = with lib.licenses; [
                gpl3Plus
                mit # for tuxemon/lib/bresenham.py
            ];
            maintainers = [maintainers.Rhys-T];
            broken = !(lib.meta.availableOn hostPlatform python3Packages.pygame-ce) || has3179;
        };
        pos = _pos;
        passthru.updateScript = let
            fixUpdater = u: u.override (old: {
                common-updater-scripts = symlinkJoin {
                    name = "tuxemon-updater-scripts-wrapper";
                    paths = [
                        (writeShellApplication {
                            name = "update-source-version";
                            runtimeInputs = [old.common-updater-scripts];
                            text = ''
                                update-source-version "$@"
                                args=()
                                for arg in "$@"; do
                                    case "$arg" in
                                        --rev=*)
                                            continue
                                            ;;
                                    esac
                                    args+=("$arg")
                                done
                                update-source-version "''${args[@]}" --ignore-same-version --source-key=data
                            '';
                        })
                        old.common-updater-scripts
                    ];
                };
            });
        in if lib.hasPrefix "v" rev then fixUpdater gitUpdater {
            rev-prefix = "v";
        } else fixUpdater unstableGitUpdater {
            tagFormat = "v*";
            tagPrefix = "v";
        };
    };
in attachPkgs pkgs tuxemon
