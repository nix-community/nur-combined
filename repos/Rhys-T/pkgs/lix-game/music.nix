{fetchzip, lib, lix-game}: fetchzip {
    pname = "${lix-game.pname}-music";
    # Upstream Last-Modified: 2023-04-15 ("Sat, 15 Apr 2023 20:58:14 GMT")
    # Snapshot taken on:      2024-09-02
    version = "0-unstable-2023-04-15";
    # Upstream archive isn't versioned - use web.archive.org to make sure the hash doesn't change on us
    url = "https://web.archive.org/web/20240902001641/https://www.lixgame.com/dow/lix-music.zip";
    hash = "sha256-JIXQ+P3AQW7EWVDHlR+Z4SWAxVAFO3d3KeB3QBGx+YQ=";
    meta = {
        description = "${lix-game.meta.description} (music files)";
        inherit (lix-game.meta) homepage;
        license = with lib.licenses; [
            cc0
            cc-by-40 # rubix
        ];
    };
}
