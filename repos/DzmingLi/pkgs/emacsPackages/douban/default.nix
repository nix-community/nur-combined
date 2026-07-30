{
  lib,
  emacsPackages,
  fetchFromGitHub,
  curl,
  pandoc,
}:

## DzmingLi/douban.el: write and publish Douban long reviews from Emacs.
##
## Consumer (with this repository's overlay enabled):
##   emacsWithPackages (epkgs: [ ... epkgs.douban ... ])
emacsPackages.trivialBuild {
  pname = "douban";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "DzmingLi";
    repo = "douban.el";
    rev = "9faa26cae19c3d1d731d40c8f9df34862a67bfcf";
    hash = "sha256-wrgs+KbOVpgE1TWANUIwl9yoQ0cuYzrKynGVOdcPYTk=";
  };

  packageRequires = [
    emacsPackages.elpaDevelPackages.plz
    emacsPackages.yaml
  ];

  postPatch = ''
    substituteInPlace douban.el \
      --replace-fail '"pandoc"' '"${lib.getExe pandoc}"'
  '';

  # plz shells out to curl.  Propagating it makes the package usable without
  # requiring every consumer to remember this non-Elisp runtime dependency.
  propagatedUserEnvPkgs = [ curl ];

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    grep -Fq '"${lib.getExe pandoc}"' douban.el
    emacs -l package -f package-initialize --batch -L . \
      --eval "(unless (require 'douban nil t) (error \"Failed to load douban\"))"
    runHook postCheck
  '';

  meta = with lib; {
    description = "Write and publish Douban long reviews from Emacs";
    homepage = "https://github.com/DzmingLi/douban.el";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
  };
}
