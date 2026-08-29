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
    rev = "ad88bf1fcbcf9dbdc7ff25e5d438bf9572cc4995";
    hash = "sha256-T4zPcFfrLWtBqqRX4s50yFFCcgwahHbZ0E59Dc5UyW4=";
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
