{ lib, fetchFromSourcehut, rustPlatform }:
rustPlatform.buildRustPackage rec {
    pname = "dolltags";
    version = "1.1.0";

    src = fetchFromSourcehut {
        owner = "~artemis";
        repo = "dolltags";
        rev = "v${version}";
        hash = "sha256-1sAMiMT8zQce38U1kBDLv72ser2J+JWRQnmyC2IDOfs=";
    };

    cargoHash = "sha256-K+CqDyU0pLyKWhsd9DHlRdm9eLKmH+CjNTOBguIqeCo=";

    postInstall =
        ''
        mkdir $out/lib
        cp -r assets $out/lib/
        cp -r templates $out/lib/
        '';

    meta = with lib; {
        description = "like dog tags but for dolls and entities of all kinds.";
        homepage = "https://git.sr.ht/~artemis/dolltags";
        mainprogram = "dolltags";
    };
}
