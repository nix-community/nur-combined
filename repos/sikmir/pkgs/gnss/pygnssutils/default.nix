{
  lib,
  fetchFromGitHub,
  python3Packages,
  pyspartn,
  pyubx2,
}:

python3Packages.buildPythonPackage rec {
  pname = "pygnssutils";
  version = "1.0.26";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pygnssutils";
    rev = "v${version}";
    hash = "sha256-wIYSBuB0sXuVu3/WUBWyod+OccXPamhXUtb1T4EiclQ=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "certifi>=2024.0.0" "certifi"
  '';

  build-system = with python3Packages; [ setuptools ];

  propagatedBuildInputs = with python3Packages; [
    certifi
    paho-mqtt
    pyserial
    pyspartn
    pyubx2
  ];

  pythonImportsCheck = [ "pygnssutils" ];

  meta = {
    description = "GNSS Command Line Utilities";
    inherit (src.meta) homepage;
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
