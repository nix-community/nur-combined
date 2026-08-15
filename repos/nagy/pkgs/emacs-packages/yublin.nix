{
  lib,
  melpaBuild,
  fetchFromGitHub,
}:

melpaBuild {
  pname = "yublin";
  version = "0-unstable-2026-08-09";

  src = fetchFromGitHub {
    owner = "nagy";
    repo = "yublin.el";
    rev = "d851b54e88e0e55cdc124a833303b721b890221b";
    hash = "sha256-/O6N5w/dgo3EdUEW+pGlYamnjgwQ5xJV26Fjsyn6L8A=";
  };

  turnCompilationWarningToError = true;

  checkPhase = ''
    runHook preCheck
    emacs --batch -L . \
      -l yublin-tests.el \
      -f ert-run-tests-batch-and-exit
    runHook postCheck
  '';

  doCheck = true;

  meta = {
    homepage = "https://github.com/nagy/yublin.el";
    description = "Yublin shorthand expansion for Emacs";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
