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
  version = "0.2.4";

  src = fetchFromCodeberg {
    owner = "hsctech";
    repo = "blobl_sitter";
    rev = "e45bf9f42777ea4c8d353694118e30f34f2a0aa0"; # v0.2.4
    hash = "sha256-fFQ98/j0FofrR4MKTZxYqMgpKCM+KBwUe+Pi+il7Sb4=";
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
