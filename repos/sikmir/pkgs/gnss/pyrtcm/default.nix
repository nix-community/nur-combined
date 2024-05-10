{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "pyrtcm";
  version = "1.0.19";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pyrtcm";
    rev = "v${version}";
    hash = "sha256-GKSh/lM5Bhmqw26ZfLQyRJMWfI8I9dGTkqDdr2CXZTs=";
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
