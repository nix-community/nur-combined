{
  lib,
  emacsPackages,
  fetchFromGitHub,
  browser-cookies,
  org-typst-math,
  typst,
}:

## DzmingLi/zhihu.el: write and publish Zhihu answers and articles from Emacs.
##
## Consumer (with this repository's overlay enabled):
##   emacsWithPackages (epkgs: [ ... epkgs.zhihu ... ])
emacsPackages.trivialBuild {
  pname = "zhihu";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "DzmingLi";
    repo = "zhihu.el";
    rev = "7eccf206b38df8bfbceaa9d8cfb5d472798fe1ea";
    hash = "sha256-xhefOwifg+RN8Lcx1JL+fK+mH/M9UTlYjIEn//dTlS4=";
  };

  packageRequires = [
    browser-cookies
    emacsPackages.elpaDevelPackages.plz
    org-typst-math
  ];

  turnCompilationWarningToError = true;

  # The remaining Typst CLI use is SVG -> PNG rasterization during image
  # upload.  Math conversion goes through the org-typst-math helper instead.
  postPatch = ''
    substituteInPlace zhihu.el \
      --replace-fail '"typst"' '"${lib.getExe typst}"'
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    grep -Fq '"${lib.getExe typst}"' zhihu.el
    emacs -l package -f package-initialize --batch -L . \
      --eval "(unless (require 'zhihu nil t) (error \"Failed to load zhihu\"))"
    runHook postCheck
  '';

  meta = with lib; {
    description = "Write and publish Zhihu answers and articles from Emacs";
    homepage = "https://github.com/DzmingLi/zhihu.el";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    broken = versionOlder emacsPackages.emacs.version "31";
  };
}
