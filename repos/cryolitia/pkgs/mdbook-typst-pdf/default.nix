{ lib
, rustPlatform'
, fetchFromGitHub
, stdenv
}:
let
  source = lib.importJSON ./pin.json;
in
rustPlatform'.buildRustPackage {
  pname = "mdbook-typst-pdf";
  version = source.version;

  src = fetchFromGitHub {
    owner = "KaiserY";
    repo = "mdbook-typst-pdf";
    rev = "v${source.version}";
    hash = source.hash;
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "typst-0.11.0" = "sha256-RbkirnVrhYT/OuZSdJWMOvQXAeBmsFICsCrezyT6ukA=";
    };
  };

  meta = with lib; {
    description = "将 mdBook 转换为 PDF。";
    homepage = "https://github.com/KaiserY/mdbook-typst-pdf";
    license = licenses.asl20;
    maintainers = with maintainers; [ Cryolitia ];
    broken = stdenv.buildPlatform != stdenv.hostPlatform;
  };
}
