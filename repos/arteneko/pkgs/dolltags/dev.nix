{ lib, fetchFromSourcehut, rustPlatform }:
let
  rev = "483142d2cc8e1204b114da872e260b0adddd4558";
in rustPlatform.buildRustPackage rec {
    pname = "dolltags-dev";
    version = "dev-${rev}";

    src = fetchFromSourcehut {
        owner = "~artemis";
        repo = "dolltags";
        rev = rev;
        hash = "sha256-ufwuoLXtOc7toW0kD30sqYmLwKHUGvYPp0hrkVOwSa8=";
    };

    cargoHash = "sha256-mlvIx38Snvt7DzffEET7g4qo/royg1Hyw/ge3a8NdIM=";

    postInstall =
        ''
        mkdir $out/lib
        cp -r assets $out/lib/
        cp -r templates $out/lib/
        '';

    meta = with lib; {
        description = "[dev branch version] like dog tags but for dolls and entities of all kinds.";
        homepage = "https://git.sr.ht/~artemis/dolltags";
        mainprogram = "dolltags";
    };
}
