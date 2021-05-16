{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "kineto";
  version = "2021-02-25";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = pname;
    rev = "edd4fe31f16f9eb9565d2b6a329738ceedea8de9";
    hash = "sha256-qRBD9b4Vtb23pzsnSwbNly/EUtptCdmM+gq2HMt3jbY=";
  };

  vendorSha256 = "sha256-+CLJJ4najojIE/0gMlhZxb1P7owdY9+cTnRk+UmHogk=";

  meta = with lib; {
    description = "An HTTP to Gemini proxy";
    inherit (src.meta) homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
