{ lib, buildGoModule, fetchFromSourcehut, scdoc }:

buildGoModule rec {
  pname = "kiln";
  version = "0.2.1";

  src = fetchFromSourcehut {
    owner = "~adnano";
    repo = pname;
    rev = version;
    hash = "sha256-c6ed62Nn++qw+U/DCiYeGwF77YsBxexWKZ7UQ3LE4fI=";
  };

  nativeBuildInputs = [ scdoc ];

  vendorSha256 = "sha256-bMpzebwbVHAbBtw0uuGyWd4wnM9z6tlsEQN4S/iucgk=";

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
