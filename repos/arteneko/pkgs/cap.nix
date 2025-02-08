{ lib, fetchFromSourcehut, rustPlatform }:
rustPlatform.buildRustPackage rec {
    pname = "cap";
    version = "d213e17e4a4b2905a5c3d6b245930c112b159f05";

    src = fetchFromSourcehut {
        owner = "~artemis";
        repo = "cap";
        rev = "${version}";
        hash = "sha256-XOE68vmjFSM2SF2v3oAgo7uOjhMFjRjaDhk5DkIjTno=";
    };

    cargoHash = "sha256-DAFORuj7Zxzqtp4Zs0N8fTfx8gZK3bbQz3C81Ye37fc=";
    meta = with lib; {
        description = "my versatile static site generator";
        homepage = "https://git.sr.ht/~artemis/cap";
        mainprogram = "cap";
    };
}
