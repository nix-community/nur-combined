{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "mercantile";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "mapbox";
    repo = pname;
    rev = version;
    hash = "sha256-DiDXO2XnD3We6NhP81z7aIHzHrHDi/nkqy98OT9986w=";
  };

  propagatedBuildInputs = with python3Packages; [ click ];

  checkInputs = with python3Packages; [ pytestCheckHook hypothesis ];

  meta = with lib; {
    description = "Spherical mercator tile and coordinate utilities";
    homepage = "http://mercantile.readthedocs.io/en/latest/";
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
