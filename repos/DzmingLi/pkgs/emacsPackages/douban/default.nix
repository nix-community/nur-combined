{
  lib,
  emacsPackages,
  fetchFromGitHub,
  browser-cookies,
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
    rev = "d0380518bcf3da4f9b5adf8af7ceb8180b3ad66f";
    hash = "sha256-9w4ijmUpBRqsLf88uHsOTmRvPeRnXhQnpRVipvAbQeE=";
  };

  packageRequires = [
    browser-cookies
    emacsPackages.elpaDevelPackages.plz
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
