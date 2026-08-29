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
    rev = "24e584ab9fb70be2d583f93edef31899d44bf1d9";
    hash = "sha256-+0orc2yDvyCXETqTd19JiILoSePj+Nci2xppsfOWGxI=";
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
