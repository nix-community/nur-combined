{ lib, fetchFromSourcehut, rustPlatform }:
let
  rev = "761e1daf23b83a6795e2cdf38e6b851af439ed70";
in rustPlatform.buildRustPackage rec {
    pname = "dolltags-dev";
    version = "dev-${rev}";

    src = fetchFromSourcehut {
        owner = "~artemis";
        repo = "dolltags";
        rev = rev;
        hash = "sha256-csxPzZyziJQ8fkAat/Sd5qf3CuATLIzu+8uoJ7TqODo=";
    };

    cargoHash = "sha256-Pymq5wQu2DQo1IeWISLWwJrWrGqRW+q4Mb6ZJlgWBMU=";

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
