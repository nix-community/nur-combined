{ lib, stdenv, python3Packages, fetchFromGitHub, maprec }:

python3Packages.buildPythonPackage rec {
  pname = "ozi_map";
  version = "2019-10-24";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "ozi_map";
    rev = "4d6bd3f234960ba90d82e6d58da9c1bf4677eb16";
    hash = "sha256-sbAKi9GZEPmbI1Nq3l4uSh/tVNLXAY2siXu3YtHI5qo=";
  };

  postPatch = "2to3 -n -w ozi_map/*.py";

  propagatedBuildInputs = with python3Packages; [ maprec pyproj ];

  doCheck = false;

  pythonImportsCheck = [ "ozi_map" ];

  meta = with lib; {
    description = "Python module for reading OziExplorer .map files";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
  };
}
