{ fetchzip, lib, common }: fetchzip rec {
    pname = "${common.pname}-music";
    # Upstream Last-Modified: 2023-04-15 ("Sat, 15 Apr 2023 20:58:14 GMT")
    # Snapshot taken on:      2024-09-02
    # Last-Modified changed later, but file content was the same
    # New Last-Modified:      2025-01-06 ("Mon, 06 Jan 2025 19:02:34 GMT")
    version = "0-unstable-2023-04-15";
    # Upstream archive isn't versioned - make sure the hash doesn't change on us
    # See also: https://github.com/SimonN/LixD/issues/457
    urls = [
        "https://media.githubusercontent.com/media/Rhys-T/nur-packages/78d0c2965aeefcdf611c56624698ecb512245e4f/lix-music-${version}.zip"
        "https://web.archive.org/web/20240902001641id_/https://www.lixgame.com/dow/lix-music.zip"
        # If all else fails, extract it from the binary release of the game and fix it up in postFetch:
        "https://github.com/SimonN/LixD/releases/download/v${common.version}/lix-${common.version}-linux64.zip"
    ];
    postFetch = ''
        shopt -s extglob
        if [[ -d "$out"/music ]]; then
            pushd "$out"
            rm -r ./!(music)
            mv music/* .
            rmdir music
            popd
        fi
        shopt -u extglob
    '';
    hash = "sha256-JIXQ+P3AQW7EWVDHlR+Z4SWAxVAFO3d3KeB3QBGx+YQ=";
    meta = common.meta // {
        description = "${common.meta.description} (music files)";
        license = with lib.licenses; [
            cc0
            cc-by-40 # rubix
        ];
    };
}
