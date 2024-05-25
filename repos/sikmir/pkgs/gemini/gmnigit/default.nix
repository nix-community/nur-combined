{
  lib,
  buildGoModule,
  fetchFromSourcehut,
}:

buildGoModule rec {
  pname = "gmnigit";
  version = "0-unstable-2022-01-10";

  src = fetchFromSourcehut {
    owner = "~kornellapacz";
    repo = "gmnigit";
    rev = "b266bf6f6d32162d83df91c35ab4f43e3da445eb";
    hash = "sha256-as8WpwJFX/sXsUueLIchcBj8/FWKCpEB5vdZBZe4xpU=";
  };

  vendorHash = "sha256-/UIfgwPFZxdnSywA7ysyVIFQXTRud/nlkOdzGEESEbY=";

  meta = {
    description = "Static git gemini viewer";
    inherit (src.meta) homepage;
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "gmnigit";
  };
}
