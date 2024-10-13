{ fetchzip, lib, common }: fetchzip {
    pname = "${common.pname}-music";
    # Upstream Last-Modified: 2023-04-15 ("Sat, 15 Apr 2023 20:58:14 GMT")
    # Snapshot taken on:      2024-09-02
    version = "0-unstable-2023-04-15";
    # Upstream archive isn't versioned - make sure the hash doesn't change on us
    urls = [
        "https://media.githubusercontent.com/media/Rhys-T/nur-packages/f77995a2952eacba9bef8c0af1603119a906770a/lix-music.zip"
        "https://web.archive.org/web/20240902001641/https://www.lixgame.com/dow/lix-music.zip"
    ];
    hash = "sha256-JIXQ+P3AQW7EWVDHlR+Z4SWAxVAFO3d3KeB3QBGx+YQ=";
    meta = common.meta // {
        description = "${common.meta.description} (music files)";
        license = with lib.licenses; [
            cc0
            cc-by-40 # rubix
        ];
    };
}
