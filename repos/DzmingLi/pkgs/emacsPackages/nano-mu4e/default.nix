{
  lib,
  emacsPackages,
  fetchFromGitHub,
}:

## rougier/nano-mu4e: opinionated, thread-first replacement for mu4e's
## headers renderer.  It keeps mu4e's search, compose, view, and mark backends.
##
## Consumer (with this repository's overlay enabled):
##   emacsWithPackages (epkgs: [ ... epkgs.mu4e epkgs.nano-mu4e ... ])
emacsPackages.trivialBuild {
  pname = "nano-mu4e";
  version = "unstable-2026-08-10";

  src = fetchFromGitHub {
    owner = "rougier";
    repo = "nano-mu4e";
    rev = "7a5f1bee58c598bd7ca36193c14dc78245da57f0";
    hash = "sha256-xfMHM26xY3/MtWPu2nvPu+6bW+vgpi4jWkswEQdQZs8=";
  };

  packageRequires = [ emacsPackages.mu4e ];

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    emacs -l package -f package-initialize --batch -L . \
      --eval "(progn
                 (require 'nano-mu4e)
                 (unless (and (fboundp 'nano-mu4e-mode)
                              (fboundp 'nano-mu4e-mark-execute-all))
                   (error \"nano-mu4e entry points are unavailable\")))"
    runHook postCheck
  '';

  meta = with lib; {
    description = "Opinionated thread-first headers view for mu4e";
    homepage = "https://github.com/rougier/nano-mu4e";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
  };
}
