{ lib, fetchFromSourcehut, rustPlatform }:
let
  rev = "0ec1c988bcc2f41fad586fdfef55091b7ddf4faf";
in rustPlatform.buildRustPackage rec {
    pname = "dolltags-dev";
    version = "dev-${rev}";

    src = fetchFromSourcehut {
        owner = "~artemis";
        repo = "dolltags";
        rev = rev;
        hash = "sha256-1sAMiMT8zQce38U1kBDLv72ser2J+JWRQnmyC2IDOfs=";
    };

    cargoHash = "sha256-jvInZqx8cBFcldRSVhBnkf7oTa4UiJGJ2T5MwIDfMIQ=";

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
