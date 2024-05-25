{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "pysheds";
  version = "0.3.5";

  src = fetchFromGitHub {
    owner = "mdbartos";
    repo = "pysheds";
    rev = version;
    hash = "sha256-OAc/OxqEvASpRNJL/KcE+exHGJie0oVv4fS+XXhtRcI=";
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

  meta = {
    description = "Simple and fast watershed delineation in python";
    inherit (src.meta) homepage;
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
