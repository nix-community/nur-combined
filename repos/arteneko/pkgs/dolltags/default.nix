{ lib, fetchFromSourcehut, rustPlatform }:
rustPlatform.buildRustPackage rec {
    pname = "dolltags";
    version = "1.0.2";

    src = fetchFromSourcehut {
        owner = "~artemis";
        repo = "dolltags";
        rev = "v${version}";
        hash = "sha256-hALeH0uQb7UjCSfEeQzRh/dn5KOLjDZ61HdoKbW4Grc=";
    };

    cargoHash = "sha256-iUitsb4hnF6miWKg5pZErpfjjkZQu+EPaMnAWglPMRs=";
  
    postInstall =
        ''
        mkdir -p $out/lib/${pname}
        cp -r assets $out/lib/${pname}
        '';

    meta = with lib; {
        description = "like dog tags but for dolls and entities of all kinds.";
        homepage = "https://git.sr.ht/~artemis/dolltags";
        mainprogram = "dolltags";
    };
}
