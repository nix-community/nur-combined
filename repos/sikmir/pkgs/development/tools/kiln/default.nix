{ lib, buildGoModule, fetchgit, sources }:

buildGoModule {
  pname = "kiln";
  version = "2020-11-21";

  src = fetchgit {
    url = "https://git.sr.ht/~adnano/kiln";
    rev = "832aed7ff24fb58a1b4a789bdd967ad81155b099";
    sha256 = "0xbcdgvgblvi52synksz3m436ibz4id6f66x83yq87825jsb64p5";
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
