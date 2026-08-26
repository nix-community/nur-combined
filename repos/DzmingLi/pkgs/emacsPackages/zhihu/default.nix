{
  lib,
  emacsPackages,
  fetchFromGitHub,
  pandoc,
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
    rev = "109106325caba33ce8761cc0444b7b2c0ee2bf89";
    hash = "sha256-nMNcAGPOQWdd92Kqjs/zbZqBml3HPybZYA+mnQAgO7Q=";
  };

  packageRequires = [
    emacsPackages.elpaDevelPackages.plz
    emacsPackages.markdown-mode
    emacsPackages.yaml
  ];

  turnCompilationWarningToError = true;

  postPatch = ''
    substituteInPlace zhihu.el \
      --replace-fail '"pandoc"' '"${lib.getExe pandoc}"' \
      --replace-fail '"typst"' '"${lib.getExe typst}"'
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    grep -Fq '"${lib.getExe pandoc}"' zhihu.el
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
