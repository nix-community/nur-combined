{ lib, fetchFromSourcehut, rustPlatform }:
rustPlatform.buildRustPackage rec {
    pname = "dolltags";
    version = "1.0.4";

    src = fetchFromSourcehut {
        owner = "~artemis";
        repo = "dolltags";
        rev = "v${version}";
        hash = "sha256-ENfsnTQYD9wVIO3Om8DrCLUX+bWvifaPgSFyhWUeHcM=";
    };

    cargoHash = "sha256-cA3d9bbTtLA60UFSRWnGJ4u0ocr81gWnCt8qKcX4+OQ=";

    postInstall =
        ''
        mkdir $out/lib
        cp -r assets $out/lib/
        cp -r templates $out/lib/
        '';

    meta = with lib; {
        description = "like dog tags but for dolls and entities of all kinds.";
        homepage = "https://git.sr.ht/~artemis/dolltags";
        mainprogram = "dolltags";
    };
}
