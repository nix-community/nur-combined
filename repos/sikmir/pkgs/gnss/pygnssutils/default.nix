{ lib, fetchFromGitHub, python3Packages, pyspartn, pyubx2 }:

python3Packages.buildPythonPackage rec {
  pname = "pygnssutils";
  version = "1.0.21";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pygnssutils";
    rev = "v${version}";
    hash = "sha256-x8n/CIlXnM9qW+/9hOuPZSU58ofKIhkGBRJrX8yVzMo=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "certifi>=2024.0.0" "certifi"
  '';

  nativeBuildInputs = with python3Packages; [ setuptools ];

  propagatedBuildInputs = with python3Packages; [
    certifi
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
