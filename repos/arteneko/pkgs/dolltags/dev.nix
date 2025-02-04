{ lib, fetchFromSourcehut, rustPlatform }:
let
  rev = "9eda90824367f3e851e968ba282561e85c81b73e";
in rustPlatform.buildRustPackage rec {
    pname = "dolltags-dev";
    version = "dev-${rev}";

    src = fetchFromSourcehut {
        owner = "~artemis";
        repo = "dolltags";
        rev = rev;
        hash = "sha256-W2Rqk6kGOukT3h0Epv7oT6IdhQOjcR9vYUWE0V0jj/g=";
    };

    cargoHash = "sha256-NfW/4I4FIeg78uF1jZp/s8GdqO7RkAV1YKOqdivSJLw=";

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
