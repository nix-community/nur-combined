{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "kineto";
  version = "2021-05-31";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = pname;
    rev = "988a00f1266ca3b9224235c504a1976f06f841cd";
    hash = "sha256-GmnoxeOGNlVJlKmWG0mBRWCcB1VwLlsFtyPXO8LDN/U=";
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
