{ lib, fetchurl }: fetchurl rec {
    pname = "mame-icon-from-papirus-icon-theme";
    version = "20250501";
    url = "https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/refs/tags/${version}/Papirus/32x32/apps/mame.svg";
    downloadToTemp = true;
    postFetch = ''
        install -Dm444 "$downloadedFile" "$out"/share/icons/Papirus/32x32/apps/mame.svg
    '';
    recursiveHash = true;
    hash = "sha256-99kTqQjrZ5QdTk1vFRTkf/GyLT2BSOSh2FsNqUzCr4M=";
    meta.license = lib.licenses.gpl3Only;
}
