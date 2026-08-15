{
  lib,
  fetchFromGitHub,
  emacs31,
}:

let
  melpaBuild = emacs31.pkgs.melpaBuild;
  emacsWithGrammars = emacs31.pkgs.withPackages (epkgs: [
    epkgs.treesit-grammars.with-all-grammars
  ]);
in

melpaBuild {
  pname = "toml-ts-cargo-mode";
  version = "0-unstable-2026-08-10";

  src = fetchFromGitHub {
    owner = "nagy";
    repo = "toml-ts-cargo-mode";
    rev = "8eb450cd935f6e360a1d425cf7e07202e8d49d2a";
    hash = "sha256-LVNY4ggHKiXvTrq6I5B7BrHAigqm8unXn0T7u09yxZs=";
  };

  turnCompilationWarningToError = true;

  checkPhase = ''
    runHook preCheck
    ${emacsWithGrammars}/bin/emacs --batch -L . \
      -l toml-ts-cargo-mode-tests.el \
      -f ert-run-tests-batch-and-exit
    runHook postCheck
  '';

  doCheck = true;

  meta = {
    homepage = "https://github.com/nagy/toml-ts-cargo-mode";
    description = "Cargo.toml extras for toml-ts-mode";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
