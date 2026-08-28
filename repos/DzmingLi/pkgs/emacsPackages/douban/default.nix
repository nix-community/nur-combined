{
  lib,
  emacsPackages,
  fetchFromGitHub,
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
    rev = "11327d3972cf4296ed2c8f59b823709285e94e84";
    hash = "sha256-0TGNFRIqoZY5gGwrpPwJAQd4N+BHqFHHPudFeB+4K3w=";
  };

  packageRequires = [
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
