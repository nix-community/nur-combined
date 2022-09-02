{ lib, stdenv, python3Packages, fetchFromGitHub, thinplatespline }:

python3Packages.buildPythonPackage rec {
  pname = "maprec";
  version = "2019-10-24";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "maprec";
    rev = "20f5177cae7454455b21cd5f7178f5639c02d385";
    hash = "sha256-8lLCzqy4W35/WV83aRnARuAdoBO+977nbuXJfpdOxP8=";
  };

  patches = [ ./python3.patch ];

  postPatch = "2to3 -n -w maprec/*.py";

  propagatedBuildInputs = with python3Packages; [ pyyaml pyproj thinplatespline ];

  doCheck = false;

  pythonImportsCheck = [ "maprec" ];

  meta = with lib; {
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
  };
}
