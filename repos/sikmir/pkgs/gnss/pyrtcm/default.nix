{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "pyrtcm";
  version = "1.0.15";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pyrtcm";
    rev = "v${version}";
    hash = "sha256-+1PnM4A47zXpwmr7RvAKQxgSLOvNf1v+BGbf+eHA4h0=";
  };

  nativeBuildInputs = with python3Packages; [ setuptools ];

  pythonImportsCheck = [ "pyrtcm" ];

  meta = with lib; {
    description = "RTCM3 protocol parser";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
