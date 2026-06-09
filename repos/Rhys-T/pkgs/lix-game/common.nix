{ fetchFromGitHub, lib, enet, stdenvNoCC, gitUpdater, symlinkJoin, writeShellApplication, maintainers }: rec {
    pname = "lix-game";
    version = "0.10.32";
    src = fetchFromGitHub {
        owner = "SimonN";
        repo = "LixD";
        tag = "v${version}";
        hash = "sha256-UUiJIe+SRmmAVnZ7qBG7BEoP0D6YYmpVfu19DCSWTXg=";
    };
    assetsHash = "sha256-Vc4rpXlXWFrTXJ7xbivzWQsqRmLJc6qvMiPZ05OUriU=";
    assetsPNG32Hash = "sha256-P4S/rjj5b9TwfrW8Hn7XLg0czmiQxAItsnBsVfSpFd0=";
    meta = {
        description = "Lemmings-like game with puzzles, editor, multiplayer";
        longDescription = ''
            Lix is a puzzle game inspired by Lemmings (DMA Design, 1991). Lix is free and open source.
            
            Assign skills to guide the lix through over 850 singleplayer puzzles. Design your own levels with the included editor.
            
            Attack and defend in real-time multiplayer for 2 to 8 players: Who can save the most lix?
        '';
        homepage = "https://www.lixgame.com/";
        changelog = "https://github.com/SimonN/LixD/releases/tag/v${version}";
        maintainers = [maintainers.Rhys-T];
    };
    patchEnetBindings = let
        libExtension = stdenvNoCC.hostPlatform.extensions.sharedLibrary;
    in ''
        for file in "$DUB_HOME"/packages/derelict-enet/*/derelict-enet/source/derelict/enet/enet.d; do
            substituteInPlace "$file" --replace-fail '"libenet${libExtension}"' '"${lib.getLib enet}/lib/libenet${libExtension}"'
        done
    '';
    updateScript = let
        fixUpdater = u: u.override (old: builtins.intersectAttrs old rec {
            genericUpdater = old.genericUpdater.override { inherit common-updater-scripts; };
            common-updater-scripts = symlinkJoin {
                name = "lix-game-updater-scripts-wrapper";
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
                            update-source-version "''${args[@]}" --ignore-same-version --source-key=pkgs._toUpdate.assets
                            update-source-version "''${args[@]}" --ignore-same-version --source-key=pkgs._toUpdate.assets-PNG32
                            
                            # Until I figure out how to auto-update the music, at least check it and fail if it's changed:
                            nix-build --no-out-link -A "$UPDATE_NIX_ATTR_PATH".pkgs._toUpdate.music-bin
                            nix-build --no-out-link -A "$UPDATE_NIX_ATTR_PATH".pkgs._toUpdate.music-bin --check
                        '';
                    })
                    old.common-updater-scripts
                ];
            };
        });
    in fixUpdater gitUpdater {
        rev-prefix = "v";
    };
}
