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
  version = "1.5-unstable-2026-03-20";

  format = "pyproject";

  src = fetchFromGitHub {
    owner = "alejo7797";
    repo = "khoca";
    rev = "716b721f84d56524461ae3d4631e9c92c35a1f4a";
    hash = "sha256-FdKtXZ+l9komnkIKSprg2fvWYXF+ZiozEuJIJ7mhaHA=";
  };

  build-system = with python3.pkgs; [
    cython
    meson-python
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  dependencies = with python3.pkgs; [
    py
  ];

  buildInputs = [
    gmp
    pari
  ];

  preBuild = ''
    patchShebangs src/khoca/*.py
  '';

  pythonImportsCheck = [
    "khoca"
  ];

  meta = {
    description = "Calculate sl(N)-homology of knots";
    license = lib.licenses.gpl3;
    homepage = "https://people.math.ethz.ch/~llewark/khoca.php";
    mainProgram = "khoca";
  };
}
