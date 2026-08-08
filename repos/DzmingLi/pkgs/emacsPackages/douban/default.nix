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
    rev = "6b0d5e6f5a85689d803cdad4de805fa00d1790c4";
    hash = "sha256-DLrtkxN0i54U0vGmV0dtKn4KIzpEGRr+9M48f1uZebE=";
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
