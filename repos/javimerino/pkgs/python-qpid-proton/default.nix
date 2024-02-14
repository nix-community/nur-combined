{ python3Packages }:
python3Packages.buildPythonPackage rec {
  pname = "python-qpid-proton";
  version = "0.39.0";
  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-NiBVrmq0x/FDckfGAnV/MDKNVcCmmG1baMqXmN6fzgI=";
  };
  format = "pyproject";

  nativeBuildInputs = with python3Packages; [
    setuptools
    cffi
  ];
  pythonImportsCheck = [ "proton" ];
}
