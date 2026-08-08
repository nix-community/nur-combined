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
    rev = "8fd7e79b72c8625589b80b3f3fd0aa06d259879c";
    hash = "sha256-0Wfq1hbHKWMbuexVncvzJL6CKvu/8thgQfjJ5jpc0NE=";
  };

  packageRequires = [
    emacsPackages.elpaDevelPackages.plz
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
  };
}
