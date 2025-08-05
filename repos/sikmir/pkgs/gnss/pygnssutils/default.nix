{
  lib,
  fetchFromGitHub,
  python3Packages,
  pysbf2,
  pyspartn,
  pyubx2,
  pyubxutils,
}:

python3Packages.buildPythonPackage rec {
  pname = "pygnssutils";
  version = "1.1.16";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pygnssutils";
    tag = "v${version}";
    hash = "sha256-zDPkVZ1lDQCWVNcHLW+E31H4Xe266mCHiILgJVyYrk8=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    certifi
    paho-mqtt
    pysbf2
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
