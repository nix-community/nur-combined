{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "rio-mucho";
  version = "1.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mapbox";
    repo = "rio-mucho";
    tag = version;
    hash = "sha256-yr79Lb02vxp2CN+638S8CFxbtim+zrkjxhjwEkx0XsY=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    click
    numpy
    rasterio
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "Parallel processing wrapper for rasterio";
    homepage = "https://github.com/mapbox/rio-mucho";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
