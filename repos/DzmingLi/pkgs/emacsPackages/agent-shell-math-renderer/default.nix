{
  lib,
  emacsPackages,
  fetchFromGitHub,
}:

## alberti42/agent-shell-math-renderer: render LaTeX from Agent Shell's
## streaming Markdown through the public render-hook API.  The runtime TeX
## toolchain (`latex' + `dvisvgm') belongs in the consumer configuration so
## users can choose its size and package set independently of this Elisp.
emacsPackages.trivialBuild {
  pname = "agent-shell-math-renderer";
  version = "0.1.0-unstable-2026-07-24";

  src = fetchFromGitHub {
    owner = "alberti42";
    repo = "agent-shell-math-renderer";
    rev = "d2dac88e27ae9a2da66bcbc68808bb6217c347ab";
    hash = "sha256-GzDPZumhXbbEPvtWyjVZ5Dkqt7EUof3yyZ9qF9kqOWw=";
  };

  packageRequires = [ emacsPackages.agent-shell ];

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    emacs -l package -f package-initialize --batch -L . \
      -l tests/agent-shell-math-renderer-tests.el \
      -f ert-run-tests-batch-and-exit
    runHook postCheck
  '';

  meta = with lib; {
    description = "Render LaTeX math in Agent Shell's streamed Markdown output";
    homepage = "https://github.com/alberti42/agent-shell-math-renderer";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
  };
}
