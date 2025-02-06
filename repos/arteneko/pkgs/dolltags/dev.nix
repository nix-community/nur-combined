{ lib, fetchFromSourcehut, rustPlatform }:
let
  rev = "8fde98e9d52338da89da54f7792ff52764ad6140";
in rustPlatform.buildRustPackage rec {
    pname = "dolltags-dev";
    version = "dev-${rev}";

    src = fetchFromSourcehut {
        owner = "~artemis";
        repo = "dolltags";
        rev = rev;
        hash = "sha256-hnhNPNZ3qWyWwHhA8uU4kLOkY93Wgpym68SsfP8+OIw=";
    };

    cargoHash = "sha256-nXnDz/k70n59ShCDmZQjmwXbVGsa6dqsnwNKwtKYGqM=";

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
