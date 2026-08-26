{
  lib,
  emacsPackages,
  fetchFromGitHub,
  pandoc,
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
    rev = "824b7e624a39afa0cb9d44768066be772c994c05";
    hash = "sha256-6VLFOk0/wwd92WMwKCfiW71Wx+SiCS+sEgRwFP7Pt3M=";
  };

  packageRequires = [
    emacsPackages.elpaDevelPackages.plz
    emacsPackages.markdown-mode
    emacsPackages.yaml
  ];

  turnCompilationWarningToError = true;

  postPatch = ''
    substituteInPlace douban.el \
      --replace-fail '"pandoc"' '"${lib.getExe pandoc}"'
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    grep -Fq '"${lib.getExe pandoc}"' douban.el
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
