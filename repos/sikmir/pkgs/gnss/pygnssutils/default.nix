{
  lib,
  fetchFromGitHub,
  python3Packages,
  pyspartn,
  pyubx2,
}:

python3Packages.buildPythonPackage rec {
  pname = "pygnssutils";
  version = "1.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pygnssutils";
    rev = "v${version}";
    hash = "sha256-FCLvqs0B33WWN0F41X7PvdMSab9JwpJDFB6ycy/R6G8=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "certifi>=2024.0.0" "certifi"
  '';

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
