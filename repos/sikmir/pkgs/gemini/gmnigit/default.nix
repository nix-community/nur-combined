{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "gmnigit";
  version = "2022-01-10";

  src = fetchFromSourcehut {
    owner = "~kornellapacz";
    repo = pname;
    rev = "b266bf6f6d32162d83df91c35ab4f43e3da445eb";
    hash = "sha256-as8WpwJFX/sXsUueLIchcBj8/FWKCpEB5vdZBZe4xpU=";
  };

  vendorHash = "sha256-/UIfgwPFZxdnSywA7ysyVIFQXTRud/nlkOdzGEESEbY=";

  meta = with lib; {
    description = "Static git gemini viewer";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
