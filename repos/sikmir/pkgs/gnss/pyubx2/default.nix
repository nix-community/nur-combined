{
  lib,
  fetchFromGitHub,
  python3Packages,
  pyrtcm,
}:

python3Packages.buildPythonPackage rec {
  pname = "pyubx2";
  version = "1.2.48";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pyubx2";
    rev = "v${version}";
    hash = "sha256-o4OkXMBo0lE+cL/l/ib6EXLEr4n/T/1YwdbxJ5zbufs=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pynmeagps
    pyrtcm
  ];

  pythonImportsCheck = [ "pyubx2" ];

  meta = {
    description = "UBX protocol parser and generator";
    homepage = "https://github.com/semuconsulting/pyubx2";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
