{ fetchFromGitHub, lib, enet, stdenvNoCC, maintainers }: rec {
    pname = "lix-game";
    version = "0.10.31";
    src = fetchFromGitHub {
        owner = "SimonN";
        repo = "LixD";
        tag = "v${version}";
        hash = "sha256-QdUF/wddgJvpyICcozYPq6mU59GMf2OFT1UjHAU7C4c=";
    };
    assetsHash = "sha256-sbFJA/v6kMcnU7Kj0Uu70QxDQ/qFnGnsCjm//EOB5ic=";
    assetsPNG32Hash = "sha256-f8tlBQWo/dPzaNk0q5x0tGLd0cctY0AH+3lh9ocMmc8=";
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
