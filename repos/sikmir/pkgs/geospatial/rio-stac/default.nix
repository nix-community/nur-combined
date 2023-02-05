{ lib, stdenv, fetchFromGitHub, python3Packages, pystac }:

python3Packages.buildPythonPackage rec {
  pname = "rio-stac";
  version = "0.6.1";
  format = "flit";

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "rio-stac";
    rev = version;
    hash = "sha256-1xIXI2fLuJmDuhLn3AZRCm+TeAmAhBsD+B4PkX07e4M=";
  };

  nativeBuildInputs = with python3Packages; [ flit-core ];

  propagatedBuildInputs = with python3Packages; [
    rasterio
    pystac
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook jsonschema ];

  disabledTests = [
    "test_create_item"
  ];

  meta = with lib; {
    description = "Create STAC item from raster datasets";
    homepage = "https://developmentseed.org/rio-stac/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
