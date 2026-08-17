{
  lib,
  melpaBuild,
  fetchFromGitHub,
}:

melpaBuild {
  pname = "crate";
  version = "0-unstable-2026-08-07";

  src = fetchFromGitHub {
    owner = "nagy";
    repo = "crate.el";
    rev = "5763d7148c025f09ac259eb698066a927a7bced2";
    hash = "sha256-24uMpyuO6MOHsmExbdEBE/7qct/Ad0r51lXNnpWt5eE=";
  };

  turnCompilationWarningToError = true;

  meta = {
    homepage = "https://github.com/nagy/crate.el";
    description = "Browse Rust crates from Emacs";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
