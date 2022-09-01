{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "kineto";
  version = "2021-08-25";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = pname;
    rev = "a8c54c1a32764d38727fb7c9f02ed9bc298e3174";
    hash = "sha256-yRFH0pf/ocsug99spAupRYQpAFnt48f8FfgZdMS0i40=";
  };

  vendorHash = "sha256-+CLJJ4najojIE/0gMlhZxb1P7owdY9+cTnRk+UmHogk=";

  meta = with lib; {
    description = "An HTTP to Gemini proxy";
    inherit (src.meta) homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
