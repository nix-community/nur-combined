{ lib, fetchFromSourcehut, rustPlatform }:
rustPlatform.buildRustPackage rec {
    pname = "dolltags";
    version = "2.0.0";

    src = fetchFromSourcehut {
        owner = "~artemis";
        repo = "dolltags";
        rev = "v${version}";
        hash = "sha256-mEqIO2sKcAHxAa0NA5g6NEr6okrPdz+1d6YEPO9H5Y8=";
    };

    cargoHash = "sha256-qHGoMNhIfQjdrFwWKOgDxlb/3M2uXq9RtHssTo9jj88=";

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
