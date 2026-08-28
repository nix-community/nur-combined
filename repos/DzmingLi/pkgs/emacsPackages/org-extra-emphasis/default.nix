{
  lib,
  emacsPackages,
  fetchFromGitHub,
}:

emacsPackages.trivialBuild {
  pname = "org-extra-emphasis";
  version = "1.0-unstable-2026-01-27";

  src = fetchFromGitHub {
    owner = "QiangF";
    repo = "org-extra-emphasis";
    rev = "bc6119226ebd84e7f2efd429a03601f563c9bb4f";
    hash = "sha256-qCgbmBipJF9ZdwPuxyB9sfJVAvzi7pJ9H42ymuE95LE=";
  };

  packageRequires = [ emacsPackages.org ];

  postPatch = ''
    substituteInPlace org-extra-emphasis.el \
      --replace-fail 'org-export-before-processing-hook' \
                     'org-export-before-processing-functions' \
      --replace-fail '(pcase--flip split-string "-")' \
                     '(funcall (lambda (value) (split-string value "-")))' \
      --replace-fail '(pcase--flip string-join "")' \
                     '(funcall (lambda (value) (string-join value "")))' \
      --replace-fail '(pcase--flip map-elt :family)' \
                     '(funcall (lambda (value) (map-elt value :family)))'
  '';

  meta = with lib; {
    description = "Extra emphasis markers for Org mode";
    homepage = "https://github.com/QiangF/org-extra-emphasis";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
  };
}
