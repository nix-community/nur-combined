{ lib, stdenv, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "xyzservices";
  version = "2022.6.0";
  disabled = python3Packages.pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "geopandas";
    repo = "xyzservices";
    rev = version;
    hash = "sha256-zfLRJLDTitzzcg5LRqaNcrgnL8ruZcTgugso/5wqS9Q=";
  };

  checkInputs = with python3Packages; [ pytestCheckHook requests mercantile ];

  meta = with lib; {
    description = "Source of XYZ tiles providers";
    homepage = "https://xyzservices.readthedocs.io/";
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
