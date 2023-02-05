{ lib, stdenv, fetchFromGitHub, python3Packages, morecantile, pystac, color-operations }:

python3Packages.buildPythonPackage rec {
  pname = "rio-tiler";
  version = "4.1.6";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "cogeotiff";
    repo = "rio-tiler";
    rev = version;
    hash = "sha256-UeAsQ82Lg5aksUdGvcrw/gcTmCJhWnCQkbrcbmqYNgc=";
  };

  nativeBuildInputs = with python3Packages; [ hatchling ];

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

  doCheck = false;

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  pythonImportsCheck = [ "rio_tiler" ];

  meta = with lib; {
    description = "User friendly Rasterio plugin to read raster datasets";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
