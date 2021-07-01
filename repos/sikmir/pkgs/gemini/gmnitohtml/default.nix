{ lib, buildGoModule, fetchFromSourcehut, scdoc }:

buildGoModule rec {
  pname = "gmnitohtml";
  version = "0.1.1";

  src = fetchFromSourcehut {
    owner = "~adnano";
    repo = pname;
    rev = version;
    hash = "sha256-XcHJbqmfSkW6lt2xRlrf9AJfwLOZqdgsL1v0aK2bQwo=";
  };

  nativeBuildInputs = [ scdoc ];

  vendorSha256 = "sha256-Cx8x8AISRVTA4Ufd73vOVky97LX23NkizHDingr/zVk=";

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
