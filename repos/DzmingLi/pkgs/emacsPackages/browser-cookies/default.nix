{
  lib,
  emacsPackages,
  fetchFromGitHub,
}:

## DzmingLi/browser-cookies.el: read cookies from explicitly selected browser
## profiles without duplicating browser-specific database and crypto logic.
emacsPackages.trivialBuild {
  pname = "browser-cookies";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "DzmingLi";
    repo = "browser-cookies.el";
    rev = "c921c88a7b34b6fae92482edb2553785090d785f";
    hash = "sha256-a0zfT3BUVlxa7pHoOCiixlqcGznr4MnXThDtQNQrQJ0=";
  };

  turnCompilationWarningToError = true;

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    emacs -l package -f package-initialize --batch -L . -L test \
      -l test/browser-cookies-test.el \
      -f ert-run-tests-batch-and-exit
    runHook postCheck
  '';

  meta = with lib; {
    description = "Read cookies from explicitly selected browser profiles in Emacs";
    homepage = "https://github.com/DzmingLi/browser-cookies.el";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
  };
}
