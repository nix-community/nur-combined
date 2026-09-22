{
  lib,
  emacsPackages,
  fetchFromGitHub,
}:

## DzmingLi/firefox-cookies.el: read cookies from an explicitly selected
## Firefox profile.
emacsPackages.trivialBuild {
  pname = "firefox-cookies";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "DzmingLi";
    repo = "firefox-cookies.el";
    rev = "42fe582db59622d0f53e4cbe24f150a2b55cdf0d";
    hash = "sha256-unUSFX2IVt5ynYOhiu87K2bdBfWgHxNUpwiYG17DqS4=";
  };

  turnCompilationWarningToError = true;

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    emacs -l package -f package-initialize --batch -L . -L test \
      -l test/firefox-cookies-test.el \
      -f ert-run-tests-batch-and-exit
    runHook postCheck
  '';

  meta = with lib; {
    description = "Read cookies from an explicitly selected Firefox profile in Emacs";
    homepage = "https://github.com/DzmingLi/firefox-cookies.el";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
  };
}
