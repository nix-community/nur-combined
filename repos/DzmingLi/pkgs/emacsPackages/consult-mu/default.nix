{
  lib,
  emacsPackages,
  fetchFromGitHub,
}:

# consult-mu is not distributed through ELPA/MELPA.  Package the main search
# frontend together with the upstream extras (compose and contacts) so overlay
# consumers get the complete feature set from one derivation.
emacsPackages.trivialBuild {
  pname = "consult-mu";
  version = "1.0-unstable-2026-09-01";

  src = fetchFromGitHub {
    owner = "armindarvish";
    repo = "consult-mu";
    rev = "8b54bbf86c2f112e3520eeeefb70d509b4590385";
    hash = "sha256-nxutBOEO6qiPjSo7y3t1KWYb0n0AMKGl943N+uGTTjQ=";
  };

  # trivialBuild installs top-level Elisp files.  Flatten upstream's extras so
  # consult-mu-compose and consult-mu-contacts are installed and compiled too.
  postPatch = ''
    cp extras/*.el .
  '';

  packageRequires = with emacsPackages; [
    consult
    embark
    goto-chg
    mu4e
  ];

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    emacs -l package -f package-initialize --batch -L . \
      --eval "(progn
                 (require 'consult-mu)
                 (require 'consult-mu-compose)
                 (require 'consult-mu-embark)
                 (require 'consult-mu-compose-embark)
                 (unless (and (fboundp 'consult-mu)
                              (fboundp 'consult-mu-compose-attach)
                              (fboundp 'consult-mu-compose-detach)
                              (fboundp 'goto-last-change))
                   (error \"consult-mu entry points are unavailable\")))"
    runHook postCheck
  '';

  meta = with lib; {
    description = "Consult-based asynchronous search and compose tools for mu4e";
    homepage = "https://github.com/armindarvish/consult-mu";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
  };
}
