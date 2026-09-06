{
  lib,
  melpaBuild,
  fetchFromGitHub,
  bm,
  diff-hl,
  swiper,
}:

melpaBuild {
  pname = "poimap";
  version = "0.1-unstable-2026-09-06";

  src = fetchFromGitHub {
    owner = "florommel";
    repo = "poimap";
    rev = "57a1b5dd76e28dec373eaa567f78553f74429585";
    hash = "sha256-ft/RElziaF4wYDCoHsdar+QtAp0hR8JhYly1+fPV/d0=";
  };

  # The main `poimap' library only needs the built-in cl-lib/emacs.  The
  # optional provider files (poimap-bm, poimap-diff-hl, poimap-swiper) are
  # bundled and byte-compiled as part of this package, so their third-party
  # dependencies must be available at compile time.  `bm', `diff-hl' and
  # `swiper' are therefore declared as package requires; each is only
  # actually used when the corresponding provider mode is enabled.
  packageRequires = [
    bm
    diff-hl
    swiper
  ];

  # Upstream still uses the `when-let' / `if-let' macros, which are obsolete
  # as of Emacs 31.1.  Rather than patching the source, accept the warnings.
  turnCompilationWarningToError = false;

  meta = {
    homepage = "https://github.com/florommel/poimap";
    description = "Visual SVG buffer map with points of interest";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
