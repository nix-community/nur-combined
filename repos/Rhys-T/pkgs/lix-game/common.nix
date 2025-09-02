{ fetchFromGitHub, lib, enet, stdenvNoCC, maintainers }: rec {
    pname = "lix-game";
    version = "0.10.32";
    src = fetchFromGitHub {
        owner = "SimonN";
        repo = "LixD";
        tag = "v${version}";
        hash = "sha256-UUiJIe+SRmmAVnZ7qBG7BEoP0D6YYmpVfu19DCSWTXg=";
    };
    assetsHash = "sha256-Vc4rpXlXWFrTXJ7xbivzWQsqRmLJc6qvMiPZ05OUriU=";
    assetsPNG32Hash = "sha256-fvlWa4aRqbOAOw8mAfhUkajhxIx52D0+de5/AqHnDCM=";
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
}
