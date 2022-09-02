{ lib, stdenv, fetchFromGitHub, python3Packages, morecantile, pystac, rio-color }:

python3Packages.buildPythonPackage rec {
  pname = "rio-tiler";
  version = "3.1.2";

  src = fetchFromGitHub {
    owner = "cogeotiff";
    repo = "rio-tiler";
    rev = version;
    hash = "sha256-ecY3U4VB0TkYHeUy+HGOFin+LTNsbWi87+6AIOKGW7o=";
  };

  propagatedBuildInputs = with python3Packages; [
    boto3
    numexpr
    morecantile
    pystac
    rasterio
    httpx
    rio-color
    cachetools
  ];

  doCheck = false;

  checkInputs = with python3Packages; [ pytestCheckHook ];

  pythonImportsCheck = [ "rio_tiler" ];

  meta = with lib; {
    description = "User friendly Rasterio plugin to read raster datasets";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
