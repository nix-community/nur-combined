{ lib, fetchFromSourcehut, rustPlatform }:
let
  rev = "f7da45312aa118ae88010831864b4bb74043a066";
in rustPlatform.buildRustPackage rec {
    pname = "dolltags-dev";
    version = "dev-${rev}";

    src = fetchFromSourcehut {
        owner = "~artemis";
        repo = "dolltags";
        rev = rev;
        hash = "sha256-2jXBJijMUn3G/MbTkVgrf21rUtCN2/ul+6TOmYuKZxw=";
    };

    cargoHash = "sha256-D0akMVaGbZ3HSzJVumvVROlMr4evHM41JBKk5HmgXv4=";

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
