{
  lib,
  fetchFromGitHub,
  python3Packages,
  pyspartn,
  pyubx2,
}:

python3Packages.buildPythonPackage rec {
  pname = "pygnssutils";
  version = "1.1.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pygnssutils";
    tag = "v${version}";
    hash = "sha256-Z+CgfnEwBIFZHGQgk6wlb8HoyrNkTMJOu1P+p3WPCDY=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    certifi
    paho-mqtt
    pyserial
    pyspartn
    pyubx2
  ];

  pythonImportsCheck = [ "pygnssutils" ];

  meta = {
    description = "GNSS Command Line Utilities";
    homepage = "https://github.com/semuconsulting/pygnssutils";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
