{
  lib,
  fetchFromGitea,
  melpaBuild,
}:

melpaBuild {
  pname = "typst-ts-mode";
  version = "0-unstable-2025-11-05";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "meow_king";
    repo = "typst-ts-mode";
    rev = "7c2ef0d5bd2b5a8727fe6d00938c47ba562e0c94";
    hash = "sha256-D+QEfEYlxJICcdUCleWpe7+HxePLSSmV7zAwvyTL0+Q=";
  };

  meta = {
    homepage = "https://codeberg.org/meow_king/typst-ts-mode";
    description = "Typst tree sitter major mode for Emacs";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
