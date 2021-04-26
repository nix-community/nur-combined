{ lib, buildGoModule, fetchFromSourcehut, scdoc }:

buildGoModule rec {
  pname = "gmnitohtml";
  version = "2021-04-24";

  src = fetchFromSourcehut {
    owner = "~adnano";
    repo = pname;
    rev = "b3379f9536a27b689e0a5bfe87c25aacf26e8b30";
    hash = "sha256-RNrAjGTdvyP+jCXnSYtnrXSPl+l1PGVk9vjHBawzRII=";
  };

  nativeBuildInputs = [ scdoc ];

  vendorSha256 = "sha256-Cx8x8AISRVTA4Ufd73vOVky97LX23NkizHDingr/zVk=";

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
    description = "Gemini text to HTML converter";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
