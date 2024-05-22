{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  pystac,
}:

python3Packages.buildPythonPackage rec {
  pname = "rio-stac";
  version = "0.9.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "rio-stac";
    rev = version;
    hash = "sha256-ySgxzcd0mRffDGv6L0iaaE9VY7K4fnsyE6RTotgSuQ4=";
  };

  nativeBuildInputs = with python3Packages; [ flit ];

  propagatedBuildInputs = with python3Packages; [
    rasterio
    pystac
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    jsonschema
  ];

  disabledTests = [ "test_create_item" ];

  meta = with lib; {
    description = "Create STAC item from raster datasets";
    homepage = "https://developmentseed.org/rio-stac/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
