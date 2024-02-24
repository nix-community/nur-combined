{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "kineto";
  version = "0-unstable-2021-11-04";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = "kineto";
    rev = "857f8c97ebc5724f4c34931ba497425e7653894e";
    hash = "sha256-U9SjIvD0Y9Ydk7pyOS3J5xVsYf1Mwk1j8d6cSEBiJ+Q=";
  };

  vendorHash = "sha256-+CLJJ4najojIE/0gMlhZxb1P7owdY9+cTnRk+UmHogk=";

  meta = with lib; {
    description = "An HTTP to Gemini proxy";
    inherit (src.meta) homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    mainProgram = "kineto";
  };
}
