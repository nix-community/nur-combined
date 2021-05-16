{ lib, buildGoModule, fetchFromSourcehut, scdoc }:

buildGoModule rec {
  pname = "kiln";
  version = "2021-05-16";

  src = fetchFromSourcehut {
    owner = "~adnano";
    repo = pname;
    rev = "277842223e1d677bc0dca24b372a9bd772101f5f";
    hash = "sha256-xgE0UZ/SERc1LaKODb0Rurgl6DBTTUzQK+pcCXICPoM=";
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
