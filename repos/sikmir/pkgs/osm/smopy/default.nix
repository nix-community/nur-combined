{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "smopy";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "rossant";
    repo = "smopy";
    tag = "v${version}";
    hash = "sha256-QytanQQPIlQTog2tTMAwdFXWbXnU4NaA7Zqh4DXFubY=";
  };

  dependencies = with python3Packages; [
    numpy
    ipython
    pillow
    matplotlib
  ];

  pythonImportsCheck = [ "smopy" ];

  meta = {
    description = "OpenStreetMap image tiles in Python";
    homepage = "https://github.com/rossant/smopy";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
