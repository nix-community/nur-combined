{ lib, buildGoModule, fetchFromSourcehut, scdoc }:

buildGoModule rec {
  pname = "kiln";
  version = "2021-05-12";

  src = fetchFromSourcehut {
    owner = "~adnano";
    repo = pname;
    rev = "07a54e89dd58a055ab91cd7561977ca80bf686e4";
    hash = "sha256-4GhhlQ5pFnJKR9pVl+0x2qIfdvBj9vIgNdW+GvQtyg0=";
  };

  nativeBuildInputs = [ scdoc ];

  vendorSha256 = "sha256-bMpzebwbVHAbBtw0uuGyWd4wnM9z6tlsEQN4S/iucgk=";

  buildPhase = ''
    runHook preBuild
    # we use make instead of go build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make PREFIX=$out install
    runHook postInstall
  '';

  meta = with lib; {
    description = "A simple static site generator for Gemini";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
