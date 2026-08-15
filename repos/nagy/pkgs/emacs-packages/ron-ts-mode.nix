{
  lib,
  melpaBuild,
  fetchFromGitHub,
}:

melpaBuild {
  pname = "ron-ts-mode";
  version = "0-unstable-2026-08-03";

  src = fetchFromGitHub {
    owner = "nagy";
    repo = "emacs-ron-ts-mode";
    rev = "c70394d16517bfc35d33a25c51e17508529c0c92";
    hash = "sha256-TY5iYwbM2ruco4w1g40web61tIRNQbYYIZIBe49PhX0=";
  };

  meta = {
    homepage = "https://github.com/nagy/emacs-ron-ts-mode";
    description = "Tree-sitter major mode for RON (Rusty Object Notation)";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
