{ lib, fetchFromSourcehut, rustPlatform }:
let
  rev = "8e68d8bb24f1514d678dedc5a05e0d98d311769d";
in rustPlatform.buildRustPackage rec {
    pname = "dolltags-dev";
    version = "dev-${rev}";

    src = fetchFromSourcehut {
        owner = "~artemis";
        repo = "dolltags";
        rev = rev;
        hash = "sha256-W2Rqk6kGOukT3h0Epv7oT6IdhQOjcR9vYUWE0V0jj/g=";
    };

    cargoHash = "sha256-OVp9s64TCBuCwWQSilgwHEuFo5tKWRp1BsmSmPJXjAY=";

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
