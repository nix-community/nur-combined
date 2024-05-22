{
  lib,
  fetchFromGitHub,
  python3Packages,
  pyrtcm,
}:

python3Packages.buildPythonPackage rec {
  pname = "pyubx2";
  version = "1.2.39";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pyubx2";
    rev = "v${version}";
    hash = "sha256-qtfAW6KMJjITugPHxddVlwS9FeoUxIEQBwknR0hhZXE=";
  };

  build-system = with python3Packages; [ setuptools ];

  propagatedBuildInputs = with python3Packages; [
    pynmeagps
    pyrtcm
  ];

  pythonImportsCheck = [ "pyubx2" ];

  meta = with lib; {
    description = "UBX protocol parser and generator";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
