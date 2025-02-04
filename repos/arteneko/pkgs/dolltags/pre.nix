{ lib, fetchFromSourcehut, rustPlatform }:
let
  rev = "1f0589ae75197dc314c92e64fe193c524cfe50de";
in rustPlatform.buildRustPackage rec {
    pname = "dolltags-pre";
    version = "pre-${rev}";

    src = fetchFromSourcehut {
        owner = "~artemis";
        repo = "dolltags";
        rev = rev;
        hash = "sha256-d84bytta8fohcAWH5HT/wahV3MXltAKnVh74O2St96A=";
    };

    cargoHash = "sha256-O0bu0gFBwfwUCc0WrCPnN+wMqnd6NVLLNi3nZLlbYd0=";

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
