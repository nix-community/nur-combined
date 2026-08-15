{
  lib,
  melpaBuild,
  fetchFromGitHub,
}:

melpaBuild {
  pname = "derivation";
  version = "0-unstable-2026-08-08";

  src = fetchFromGitHub {
    owner = "nagy";
    repo = "derivation.el";
    rev = "6eb36888502c7095aa05e718fa4b7e66e701403d";
    hash = "sha256-zO2tKTXk68NgyyaB7HmwIqTtUbgpgXB9HmT20jry6pY=";
  };

  turnCompilationWarningToError = true;

  checkPhase = ''
    runHook preCheck
    emacs --batch -L . \
      -l derivation-tests.el \
      -f ert-run-tests-batch-and-exit
    runHook postCheck
  '';

  doCheck = true;

  meta = {
    homepage = "https://github.com/nagy/derivation.el";
    description = "Live buffer derivation via external commands";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
