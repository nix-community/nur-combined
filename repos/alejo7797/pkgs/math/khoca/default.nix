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
    rev = "aced077a5f0256726bd75b84a9510d55500419c2";
    hash = "sha256-Lz6Ljl0o1ydtJpdETMlXIzrlgfddWS7mh4kxn0dhUi0=";
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
