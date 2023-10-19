{ lib, stdenv, fetchFromGitHub, python3Packages, pystac }:

python3Packages.buildPythonPackage rec {
  pname = "rio-stac";
  version = "0.8.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "rio-stac";
    rev = version;
    hash = "sha256-3qFG8d4pz41a9jez69ka7gdix5lCbHJZcTs733CiBs4=";
  };

  nativeBuildInputs = with python3Packages; [ flit ];

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
