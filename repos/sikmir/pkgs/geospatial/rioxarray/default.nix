{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "rioxarray";
  version = "0.15.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "corteva";
    repo = "rioxarray";
    rev = version;
    hash = "sha256-bumFZQktgUqo2lyoLtDXkh6Vv5oS/wobqYpvNYy7La0=";
  };

  build-system = with python3Packages; [ setuptools ];

  propagatedBuildInputs = with python3Packages; [
    packaging
    rasterio
    xarray
    pyproj
    numpy
  ];

  doCheck = false;
  nativeCheckInputs = with python3Packages; [
    dask
    netcdf4
    pytestCheckHook
  ];

  pythonImportsCheck = [ "rioxarray" ];

  meta = with lib; {
    description = "geospatial xarray extension powered by rasterio";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
  };
}
