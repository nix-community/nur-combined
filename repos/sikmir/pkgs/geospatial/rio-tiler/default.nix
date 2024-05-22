{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  morecantile,
  pystac,
  color-operations,
  rioxarray,
}:

python3Packages.buildPythonPackage rec {
  pname = "rio-tiler";
  version = "6.6.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "cogeotiff";
    repo = "rio-tiler";
    rev = version;
    hash = "sha256-MR6kyoGM3uXt6JiIEfGcsmTmxqlLxUF9Wn+CFuK5LtQ=";
  };

  build-system = with python3Packages; [ hatchling ];

  propagatedBuildInputs = with python3Packages; [
    boto3
    numexpr
    morecantile
    pystac
    rasterio
    httpx
    cachetools
    color-operations
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    rioxarray
  ];

  pythonImportsCheck = [ "rio_tiler" ];

  meta = with lib; {
    description = "User friendly Rasterio plugin to read raster datasets";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
