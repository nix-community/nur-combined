{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "smopy";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "rossant";
    repo = "smopy";
    rev = "v${version}";
    hash = "sha256-QytanQQPIlQTog2tTMAwdFXWbXnU4NaA7Zqh4DXFubY=";
  };

  propagatedBuildInputs = with python3Packages; [
    numpy
    ipython
    pillow
    matplotlib
  ];

  pythonImportsCheck = [ "smopy" ];

  meta = with lib; {
    description = "OpenStreetMap image tiles in Python";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
