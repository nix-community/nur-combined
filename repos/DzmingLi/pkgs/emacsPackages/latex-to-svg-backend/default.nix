{
  lib,
  emacsPackages,
  fetchFromGitHub,
  texlive,
}:

let
  # The default backend preamble uses standalone[varwidth], amsmath,
  # amssymb, and xcolor.  mylatexformat powers the optional precompiled
  # preamble fast path; latex and dvisvgm perform the actual conversion.
  # dvisvgm also needs the PostScript headers shipped by dvips when the DVI
  # contains color specials.
  texRuntime = texlive.withPackages (tex: with tex; [
    latex
    latex-bin
    standalone
    varwidth
    amsmath
    amsfonts
    xcolor
    dvisvgm
    dvips
    mylatexformat
  ]);
in
emacsPackages.trivialBuild {
  pname = "latex-to-svg-backend";
  version = "0.5.0-unstable-2026-08-07";

  # Temporary pin to the pull-request branch that runs latex and dvisvgm
  # directly instead of routing them through the user's shell.
  src = fetchFromGitHub {
    owner = "DzmingLi";
    repo = "latex-to-svg-backend";
    rev = "7891dbd164b179ff4a781259aa34a25d758cf818";
    hash = "sha256-R0ZBjetRYl4dHarVk86qJn/xQ6caxCds3wDwXJyJ94w=";
  };

  # Installing the Emacs package must also make its external rendering
  # programs and the packages used by its default preamble available.
  propagatedUserEnvPkgs = [ texRuntime ];
  nativeCheckInputs = [ texRuntime ];

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    emacs --batch -Q -L . \
      -l tests/latex-to-svg-backend-tests.el \
      -f ert-run-tests-batch-and-exit
    runHook postCheck
  '';

  meta = with lib; {
    description = "Content-addressed LaTeX-to-SVG rendering backend for Emacs";
    homepage = "https://github.com/alberti42/latex-to-svg-backend";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
  };
}
