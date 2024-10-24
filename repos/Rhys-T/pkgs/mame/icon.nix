{ lib, fetchurl }: fetchurl rec {
    pname = "mame-icon-from-papirus-icon-theme";
    version = "20240501";
    url = "https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/refs/tags/${version}/Papirus/32x32/apps/mame.svg";
    downloadToTemp = true;
    postFetch = ''
        install -Dm444 "$downloadedFile" "$out"/share/icons/Papirus/32x32/apps/mame.svg
    '';
    recursiveHash = true;
    hash = "sha256-iVfep3z/2wLv9GfWjj6iThHIRKXzRW53rIwyKQicggQ=";
    meta.license = lib.licenses.gpl3Only;
}
