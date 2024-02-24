{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "pynmeagps";
  version = "1.0.33";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pynmeagps";
    rev = "v${version}";
    hash = "sha256-94VS7f9DB42WAk6wg0qplJP8IbLcmljcx/YNm4/6f/k=";
  };

  nativeBuildInputs = with python3Packages; [ setuptools ];

  pythonImportsCheck = [ "pynmeagps" ];

  meta = with lib; {
    description = "NMEA protocol parser and generator";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
