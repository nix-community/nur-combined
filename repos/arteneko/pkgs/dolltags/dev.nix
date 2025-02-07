{ lib, fetchFromSourcehut, rustPlatform }:
let
  rev = "9eb1ef335ac8e805dac8e7787acb960145ed7425";
in rustPlatform.buildRustPackage rec {
    pname = "dolltags-dev";
    version = "dev-${rev}";

    src = fetchFromSourcehut {
        owner = "~artemis";
        repo = "dolltags";
        rev = rev;
        hash = "sha256-oghQn9nmvFStiBrdB2FOEKlNqLn4V4GRuRVyN9p3EGo=";
    };

    cargoHash = "sha256-0sGnzFGrTXR6wt+DMf/aLczBYrHDo1Ag0N+QR4fp0h8=";

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
