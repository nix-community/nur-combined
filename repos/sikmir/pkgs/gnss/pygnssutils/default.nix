{
  lib,
  fetchFromGitHub,
  python3Packages,
  pyspartn,
  pyubx2,
  pyubxutils,
}:

python3Packages.buildPythonPackage rec {
  pname = "pygnssutils";
  version = "1.1.13";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pygnssutils";
    tag = "v${version}";
    hash = "sha256-9jWq2F8RrRKZfa6DwnVzRYe+t0U1kPI68wTqJd20eIc=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    certifi
    paho-mqtt
    pyserial
    pyspartn
    pyubx2
    pyubxutils
  ];

  pythonImportsCheck = [ "pygnssutils" ];

  meta = {
    description = "GNSS Command Line Utilities";
    homepage = "https://github.com/semuconsulting/pygnssutils";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
