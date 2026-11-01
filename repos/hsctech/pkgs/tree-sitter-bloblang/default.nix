{
  lib,
  fetchFromCodeberg,
  tree-sitter,
  # Accepted and forwarded so nixpkgs' helix wrapper can pin this grammar
  # via `.override { location = ...; }` like any other grammar.
  location ? null,
}:

tree-sitter.buildGrammar {
  inherit location;

  language = "bloblang";
  # No tag past v0.2.4; pinned to main (manual bumps, like helix-blobl).
  version = "0.2.4-unstable-2026-11-01";

  src = fetchFromCodeberg {
    owner = "hsctech";
    repo = "blobl_sitter";
    rev = "81d932c9d8a37059bfff62f1215a6be25e688d23"; # main, post-v0.2.4
    hash = "sha256-4gjD9qqM6MuyjQ7VZeCm/pVAnyhh5MBITpo6DWwt/eg=";
  };

  meta = {
    description = "Tree-sitter grammar for Bento's Bloblang mapping language";
    homepage = "https://codeberg.org/hsctech/blobl_sitter";
    license = lib.licenses.mit;
    maintainers = [
      {
        name = "hsctech";
        email = "henrik@hsctech.eu";
      }
    ];
  };
}
