{
  lib,
  fetchFromGitea,
  melpaBuild,
}:

melpaBuild {
  pname = "typst-ts-mode";
  version = "0-unstable-2026-11-08";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "meow_king";
    repo = "typst-ts-mode";
    rev = "5fc2e73e0391903272509452d5c12e3104face99";
    hash = "sha256-hRx2gs5DZtqnLrmIC/sJPzG2sc/TJvXQWbOBzYs7GUg=";
  };

  meta = {
    homepage = "https://codeberg.org/meow_king/typst-ts-mode";
    description = "Typst tree sitter major mode for Emacs";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
