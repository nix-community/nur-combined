{ stdenv, azahar, fetchFromGitHub }:

azahar.overrideAttrs (final: prev: {
  pname = "azahar";
  version = "2125.0-alpha6-unstable-2026-03-10";
  src = fetchFromGitHub {
    owner = "azahar-emu";
    repo = "azahar";
    rev = "e351fa56ce35d9c8f66f26943685300e883c1b96";
    hash = "sha256-tyu7mKIgMFTas4aqip3Rju8XWL4WQtZOie7DRlil2/k=";
    fetchSubmodules = true;
  };

  meta = prev.meta // {
    description = prev.meta.description + " (master branch)";
    # empty output
    broken = stdenv.isDarwin;
  };
})
