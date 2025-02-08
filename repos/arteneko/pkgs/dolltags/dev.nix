{ lib, fetchFromSourcehut, rustPlatform }:
let
  rev = "f74187843ce2476c6989615322fb57dabc48c977";
in rustPlatform.buildRustPackage rec {
    pname = "dolltags-dev";
    version = "dev-${rev}";

    src = fetchFromSourcehut {
        owner = "~artemis";
        repo = "dolltags";
        rev = rev;
        hash = "sha256-mbnTe6vi6gJEual8LSUuCBPVaBRa+7QUgr/q/veaPq8=";
    };

    cargoHash = "sha256-SaC7oXTv/XLFTv355+Odjkj9HAmB9VJngfN04BnOZNk=";

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
