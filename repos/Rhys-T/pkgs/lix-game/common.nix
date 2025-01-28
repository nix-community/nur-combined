{ fetchFromGitHub, fetchzip, lib, enet, hostPlatform, maintainers }: rec {
    pname = "lix-game";
    version = "0.10.29";
    src = fetchFromGitHub {
        owner = "SimonN";
        repo = "LixD";
        rev = "v${version}";
        hash = "sha256-R6iRjov21GmzvwX5/a9C7GPu1VE8g/JnGP9z/q4k6ew=";
    };
    assetsHash = "sha256-wyqIBsWuo8xc9tgvE4VKQhnOg7YAhF6+U04tXLt7e6g=";
    assetsPNG32Hash = "sha256-GICiOXd/Hmke78jKymxQOSHxAJAi9Bz5qHnFzTYDqqU=";
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
