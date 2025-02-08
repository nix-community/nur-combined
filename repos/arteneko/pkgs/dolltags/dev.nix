{ lib, fetchFromSourcehut, rustPlatform }:
let
  rev = "77f231c913a958a63663ebb6c0b94398f8956f4b";
in rustPlatform.buildRustPackage rec {
    pname = "dolltags-dev";
    version = "dev-${rev}";

    src = fetchFromSourcehut {
        owner = "~artemis";
        repo = "dolltags";
        rev = rev;
        hash = "sha256-mEqIO2sKcAHxAa0NA5g6NEr6okrPdz+1d6YEPO9H5Y8=";
    };

    cargoHash = "sha256-6rg1UtP5ieqLIZHXEnQO0yUdrz83yH4t9TG1D+GiXc0=";

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
