{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "gmnigit";
  version = "2021-04-16";

  src = fetchFromSourcehut {
    owner = "~kornellapacz";
    repo = pname;
    rev = "9cdc82885cf4286f621f8cb7f26c45aa4e513ad6";
    sha256 = "1wx41k3mgypacgavlnnr7z62879xs0n4986pmcqk4bjgn77471nn";
  };

  vendorSha256 = "0kjz21bzn829k10x3fvsvij4zxmi1ahq4bnk62lghrvazjbqk2r9";

  meta = with lib; {
    description = "Static git gemini viewer";
    homepage = "https://git.sr.ht/~kornellapacz/gmnigit";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
