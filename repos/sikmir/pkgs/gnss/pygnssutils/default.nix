{ lib, fetchFromGitHub, python3Packages, pyspartn, pyubx2 }:

python3Packages.buildPythonPackage rec {
  pname = "pygnssutils";
  version = "1.0.19";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pygnssutils";
    rev = "v${version}";
    hash = "sha256-Wxy4vKNaudQ0l2j5HS1b6AZx2WtCLv6h+DcrGTAihIQ=";
  };

  nativeBuildInputs = with python3Packages; [ setuptools ];

  propagatedBuildInputs = with python3Packages; [
    paho-mqtt
    pyserial
    pyspartn
    pyubx2
  ];

  pythonImportsCheck = [ "pygnssutils" ];

  meta = with lib; {
    description = "GNSS Command Line Utilities";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
