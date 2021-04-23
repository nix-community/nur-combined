{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "gmnigit";
  version = "2021-04-16";

  src = fetchFromSourcehut {
    owner = "~kornellapacz";
    repo = pname;
    rev = "9cdc82885cf4286f621f8cb7f26c45aa4e513ad6";
    hash = "sha256-1oZDzrFPLjIxq9egRCzQPR0kzD/ZWrrVY+r6V8cMpPM=";
  };

  vendorSha256 = "0kjz21bzn829k10x3fvsvij4zxmi1ahq4bnk62lghrvazjbqk2r9";

  meta = with lib; {
    description = "Static git gemini viewer";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
