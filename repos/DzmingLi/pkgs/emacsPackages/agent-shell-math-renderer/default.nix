{
  lib,
  emacsPackages,
  fetchFromGitHub,
}:

## alberti42/agent-shell-math-renderer: detect LaTeX in Agent Shell's
## streaming Markdown and delegate compilation to latex-to-svg-backend.
emacsPackages.trivialBuild {
  pname = "agent-shell-math-renderer";
  version = "0.3.1-unstable-2026-08-03";

  src = fetchFromGitHub {
    owner = "alberti42";
    repo = "agent-shell-math-renderer";
    rev = "ce7c91efe693aed197e7bc63afa263f6f0d26c11";
    hash = "sha256-iM3b03qmYUqoHFDRnTJDmT8wxMxTPRz6I/LZZMEPpr8=";
  };

  packageRequires = [
    emacsPackages.agent-shell
    emacsPackages.latex-to-svg-backend
  ];

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
