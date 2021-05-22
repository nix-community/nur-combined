{ lib, buildGoModule, fetchFromSourcehut, scdoc }:

buildGoModule rec {
  pname = "kiln";
  version = "0.2.0";

  src = fetchFromSourcehut {
    owner = "~adnano";
    repo = pname;
    rev = version;
    hash = "sha256-ERDStRh5M2X2Nnvut97IhN0PjZvS9ePMEscsLCiXWiI=";
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
