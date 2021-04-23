{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "kiln";
  version = "0.1.0";

  src = fetchFromSourcehut {
    owner = "~adnano";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-oQ5Ehev9HIzCCVr60XLmfVf+DT+nQjiWk1OkVSiCQmY=";
  };

  vendorSha256 = "1vqzbw4a2rh043cim17ys0yn33qxk0d7szxr9gkcs5dqlaa8z36y";

  meta = with lib; {
    description = "A simple static site generator for Gemini";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
