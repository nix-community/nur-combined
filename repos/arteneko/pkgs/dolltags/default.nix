{ lib, fetchFromSourcehut, rustPlatform }:
rustPlatform.buildRustPackage rec {
    pname = "dolltags";
    version = "1.2.0";

    src = fetchFromSourcehut {
        owner = "~artemis";
        repo = "dolltags";
        rev = "v${version}";
        hash = "sha256-W2Rqk6kGOukT3h0Epv7oT6IdhQOjcR9vYUWE0V0jj/g=";
    };

    cargoHash = "sha256-pyOrHznTrg0tT9B0ncCLoLDagAJbvZ7/Yfo83zDThYw=";

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
