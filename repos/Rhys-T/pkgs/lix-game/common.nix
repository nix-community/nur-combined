{ fetchFromGitHub, fetchzip, lib, enet, hostPlatform, maintainers }: rec {
    pname = "lix-game";
    version = "0.10.27";
    src = fetchFromGitHub {
        owner = "SimonN";
        repo = "LixD";
        rev = "v${version}";
        hash = "sha256-h8CXgpw++4m+FyXKavJOA2oRvMQb1ckUV3nyY+GSR3U=";
    };
    assetsHash = "sha256-t2vSn0C+KX8et+znfJZO9KUzobBx0LqRzMXajSzAPwA=";
    assetsPNG32Hash = "sha256-KoSE4EF3FC6v9X7hZc/DU8jvgGa0DU3SpFCWAu/elyk=";
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
        libExtension = hostPlatform.extensions.sharedLibrary;
    in ''
        for file in "$DUB_HOME"/packages/derelict-enet/*/derelict-enet/source/derelict/enet/enet.d; do
            substituteInPlace "$file" --replace-fail '"libenet${libExtension}"' '"${lib.getLib enet}/lib/libenet${libExtension}"'
        done
    '';
}
