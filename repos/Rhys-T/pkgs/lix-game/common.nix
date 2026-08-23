{ fetchFromGitHub, lib, enet, stdenvNoCC, gitUpdater, dub-to-nix, symlinkJoin, writeShellApplication, maintainers }: rec {
    pname = "lix-game";
    version = "0.10.34";
    src = fetchFromGitHub {
        owner = "SimonN";
        repo = "LixD";
        tag = "v${version}";
        hash = "sha256-ujITbZ4rzpwkwRQ/6Yjs/oLI1zQhqYG7OEjQeltss/g=";
    };
    assetsHash = "sha256-GmdQujTQHWHxY6L2fa3u/TupPEecyG2imjeQ/ijBicA=";
    assetsPNG32Hash = "sha256-oY6g6amdXTmNNzRH58tJVYMk+V2NfMX2+VuI+swlOjk=";
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
                        runtimeInputs = [old.common-updater-scripts dub-to-nix];
                        text = ''
                            set -x
                            args=()
                            for arg in "$@"; do
                                case "$arg" in
                                    --print-changes)
                                        printChanges=true
                                        continue
                                        ;;
                                esac
                                args+=("$arg")
                            done
                            set -- "''${args[@]}"
                            changes="$(update-source-version "$@" --print-changes)"
                            if [[ "$changes" == '[]' ]]; then
                                if [[ -n "$printChanges" ]]; then
                                    echo '[]'
                                fi
                                exit 0
                            fi
                            eval "$(jq -r '.[0].files[0] | @sh "file=\(.)"' <<< "$changes")"
                            # shellcheck disable=SC2154
                            args=("--file=$file")
                            for arg in "$@"; do
                                case "$arg" in
                                    --rev=*)
                                        continue
                                        ;;
                                esac
                                args+=("$arg")
                            done
                            set -- "''${args[@]}"
                            update-source-version "$@" --ignore-same-version --source-key=pkgs._toUpdate.assets
                            update-source-version "$@" --ignore-same-version --source-key=pkgs._toUpdate.assets-PNG32
                            
                            dubLock="''${file%/*}/dub-lock.json"
                            pushd "$(nix-build --no-out-link -A "$UPDATE_NIX_ATTR_PATH".src)" > /dev/null
                            dub-to-nix > "$dubLock.cmp"
                            popd > /dev/null
                            if ! cmp -s "$dubLock.cmp" "$dubLock"; then
                                mv -f "$dubLock.cmp" "$dubLock"
                                changes="$(jq -c --arg dubLock "$dubLock" '.[0].files += [$dubLock]' <<< "$changes")"
                            fi
                            rm -f "$dubLock.cmp"
                            
                            # Until I figure out how to auto-update the music, at least check it and fail if it's changed:
                            nix-build --no-out-link -A "$UPDATE_NIX_ATTR_PATH".pkgs._toUpdate.music-bin > /dev/null
                            nix-build --no-out-link -A "$UPDATE_NIX_ATTR_PATH".pkgs._toUpdate.music-bin --check > /dev/null
                            
                            if [[ -n "$printChanges" ]]; then
                                echo -E "$changes"
                            fi
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
