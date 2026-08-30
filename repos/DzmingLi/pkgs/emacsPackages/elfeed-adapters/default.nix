{
  lib,
  emacsPackages,
  fetchFromGitHub,
  browser-cookies,
  zhihu,
}:

emacsPackages.trivialBuild {
  pname = "elfeed-adapters";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "DzmingLi";
    repo = "elfeed-adapters";
    rev = "a689d2eaed1e1124ae680d472b18991e0e9db074";
    hash = "sha256-f1u833+ocsLK+N5GAnu8vrtTt2PtMwvV9h1lhc+/ewQ=";
  };

  packageRequires = [
    browser-cookies
    zhihu
    emacsPackages.elfeed
    emacsPackages.elpaDevelPackages.plz
  ];

  turnCompilationWarningToError = true;

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    emacs -l package -f package-initialize --batch -L . -L test \
      -l test/elfeed-adapters-test.el \
      -f ert-run-tests-batch-and-exit
    runHook postCheck
  '';

  meta = with lib; {
    description = "Native website and API adapters for Elfeed";
    homepage = "https://github.com/DzmingLi/elfeed-adapters";
    license = licenses.agpl3Plus;
    platforms = platforms.unix;
  };
}
