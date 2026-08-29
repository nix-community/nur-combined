{
  lib,
  emacsPackages,
  fetchFromGitHub,
  browser-cookies,
  org-extra-emphasis,
}:

## DzmingLi/douban.el: write and publish Douban content from Emacs.
##
## Consumer (with this repository's overlay enabled):
##   emacsWithPackages (epkgs: [ ... epkgs.douban ... ])
emacsPackages.trivialBuild {
  pname = "douban";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "DzmingLi";
    repo = "douban.el";
    rev = "caf9ecb9ed03ac7f2a86d74d98ff9adc7438e700";
    hash = "sha256-A8oP4+3W5hHPbaDtiOorM7j//jd550Q73Py9E/v9p/s=";
  };

  packageRequires = [
    browser-cookies
    emacsPackages.elpaDevelPackages.plz
    org-extra-emphasis
  ];

  turnCompilationWarningToError = true;

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    emacs -l package -f package-initialize --batch -L . \
      --eval "(unless (require 'douban nil t) (error \"Failed to load douban\"))"
    runHook postCheck
  '';

  meta = with lib; {
    description = "Write and publish Douban content from Emacs";
    homepage = "https://github.com/DzmingLi/douban.el";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    broken = versionOlder emacsPackages.emacs.version "31";
  };
}
