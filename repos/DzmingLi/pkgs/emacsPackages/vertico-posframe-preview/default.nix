{
  lib,
  emacsPackages,
  fetchFromGitHub,
}:

emacsPackages.trivialBuild {
  pname = "vertico-posframe-preview";
  version = "0.1-unstable-2026-05-05";

  src = fetchFromGitHub {
    owner = "kn66";
    repo = "vertico-posframe-preview";
    rev = "c553d5c1f099051e0e7454d6b76a5a657670d383";
    hash = "sha256-HmxayuKe522VVPGFkqFhRGu8TK5+v3bRaZ/FvouxP3Q=";
  };

  packageRequires = with emacsPackages; [
    posframe
    vertico
    vertico-posframe
  ];

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    emacs -l package -f package-initialize --batch -L . \
      -l test/vertico-posframe-preview-test.el \
      -f ert-run-tests-batch-and-exit
    runHook postCheck
  '';

  meta = with lib; {
    description = "Side-by-side floating previews for Vertico candidates";
    homepage = "https://github.com/kn66/vertico-posframe-preview";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
    broken = versionOlder emacsPackages.emacs.version "30.1";
  };
}
