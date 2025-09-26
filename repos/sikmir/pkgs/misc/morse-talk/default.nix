{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "morse-talk";
  version = "2021-06-27";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "morse-talk";
    repo = "morse-talk";
    rev = "9f3bce0fa1d30b58095a979ed20c55c0767d9993";
    hash = "sha256-ls6xipRrBKtoNV/Zmmn793fUgsuiXEDxk1+Um9mzAmY=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    matplotlib
    sounddevice
    tkinter
  ];

  meta = {
    description = "A Python library written for Morse Code";
    homepage = "https://github.com/morse-talk/morse-talk";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
