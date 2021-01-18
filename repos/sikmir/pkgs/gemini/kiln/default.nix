{ lib, buildGoModule, fetchgit, sources }:

buildGoModule rec {
  pname = "kiln";
  version = "0.1.0";

  src = fetchgit {
    url = "https://git.sr.ht/~adnano/kiln";
    rev = "v${version}";
    sha256 = "0rj2h8l5b92kjfb3hhm77w6zwmvxwrrd3yjs1718q77xxf2l83m1";
  };

  vendorSha256 = "1vqzbw4a2rh043cim17ys0yn33qxk0d7szxr9gkcs5dqlaa8z36y";

  meta = with lib; {
    description = "A simple static site generator for Gemini";
    homepage = "https://git.sr.ht/~adnano/kiln";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
