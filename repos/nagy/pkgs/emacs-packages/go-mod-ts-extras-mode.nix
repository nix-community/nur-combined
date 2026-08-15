{
  lib,
  melpaBuild,
  fetchFromGitHub,
  treesit-grammars,
}:

melpaBuild {
  pname = "go-mod-ts-extras-mode";
  version = "0-unstable-2026-08-15";

  src = fetchFromGitHub {
    owner = "nagy";
    repo = "go-mod-ts-extras-mode";
    rev = "46d6cfed2bf5d9358f2d8a6ed19d16d80edf3ef3";
    hash = "sha256-/lqh4xneJpTLq0kxXK98dUvVRvC6DNShrrLmjRIGeFo=";
  };

  packageRequires = [
    treesit-grammars.with-all-grammars
  ];

  turnCompilationWarningToError = true;

  checkPhase = ''
    runHook preCheck
    emacs --batch -L . \
      -l go-mod-ts-extras-mode-tests.el \
      -f ert-run-tests-batch-and-exit
    runHook postCheck
  '';

  doCheck = true;

  meta = {
    homepage = "https://github.com/nagy/go-mod-ts-extras-mode";
    description = "pkg.go.dev extras for go-mod-ts-mode";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
