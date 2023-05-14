{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "pysheds";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "mdbartos";
    repo = "pysheds";
    rev = version;
    hash = "sha256-p3m4FLj8nOh6EWXUqhqvc3jGwjR8/tr/ULyx6WSiAl0=";
  };

  propagatedBuildInputs = with python3Packages; [
    scikitimage
    affine
    geojson
    rasterio
    pyproj
    numba
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  doCheck = false;

  meta = with lib; {
    description = "Simple and fast watershed delineation in python";
    inherit (src.meta) homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
  };
}
