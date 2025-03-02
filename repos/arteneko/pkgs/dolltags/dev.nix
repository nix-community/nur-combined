{ lib, fetchFromSourcehut, rustPlatform }:
let
  rev = "e8634eeff18d4752411bbeb38d713fd22b4ea3e5";
in rustPlatform.buildRustPackage rec {
    pname = "dolltags-dev";
    version = "dev-${rev}";

    src = fetchFromSourcehut {
        owner = "~artemis";
        repo = "dolltags";
        rev = rev;
        hash = "sha256-w2L0MLLot3YKvX1TMWNR9nTwYJ6cOatrRN9tarSZgrs=";
    };

    cargoHash = "sha256-4AziDJ+XSkuWiy35GFCKxJ5klExjUCHQz2bgx+0v/Xk=";

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
