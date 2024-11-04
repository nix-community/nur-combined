{ fetchFromGitHub, fetchzip, lib, enet, hostPlatform, maintainers }: rec {
    pname = "lix-game";
    version = "0.10.26";
    src = fetchFromGitHub {
        owner = "SimonN";
        repo = "LixD";
        rev = "v${version}";
        hash = "sha256-cDR/7GFkFPRH8HK5k4q3PMon2tW+eyCUL9qgNBtI2rU=";
    };
    assetsHash = "sha256-KhdjR0qkNeOeJa4qIWGWOm4Ke8bVAMKk//W0hyOLPyo=";
    assetsPNG32Hash = "sha256-LRHJjK2xr1JpclIkUyRDNOIBXgi+6N4EoTeUvl3U0/8=";
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
        libExtension = if hostPlatform.isDarwin then "dylib" else "so";
    in ''
        for file in "$DUB_HOME"/packages/derelict-enet/*/derelict-enet/source/derelict/enet/enet.d; do
            substituteInPlace "$file" --replace-fail '"libenet.${libExtension}"' '"${lib.getLib enet}/lib/libenet.${libExtension}"'
        done
    '';
}
