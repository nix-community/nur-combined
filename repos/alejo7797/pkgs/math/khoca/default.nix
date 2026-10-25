{
  lib,
  fetchFromGitHub,
  python3,
  pkg-config,
  gmp,
  pari,
}:

python3.pkgs.buildPythonApplication {
  pname = "khoca";
  version = "1.6-unstable-2026-10-25";

  format = "pyproject";

  src = fetchFromGitHub {
    owner = "alejo7797";
    repo = "khoca";
    rev = "46905cc73e58c7b01ee4e63b04c2f5f9c4b9b22b";
    hash = "sha256-m+9mer97K5lgfT4P1q4UZLoc4FT++cicjX8VgXqBGxw=";
  };

  build-system = with python3.pkgs; [
    cython
    meson-python
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    gmp
    pari
  ];

  meta = {
    description = "Calculate sl(N)-homology of knots";
    license = lib.licenses.gpl3;
    homepage = "https://people.math.ethz.ch/~llewark/khoca.php";
    mainProgram = "khoca";
  };
}
