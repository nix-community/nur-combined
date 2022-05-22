{ lib, stdenv, fetchFromGitHub, python3Packages, morecantile, supermercado, rio-tiler }:

python3Packages.buildPythonPackage rec {
  pname = "cogeo-mosaic";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = pname;
    rev = version;
    hash = "sha256-6pUuCEa2O0MT5UsOjnAeF1bLlnSpmuBMoZl5s8WJZoE=";
  };

  propagatedBuildInputs = with python3Packages; [
    httpx
    morecantile
    pygeos
    cachetools
    supermercado
    rio-tiler
  ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  disabledTests = [
    "test_mosaic_crud_error" # requires network access
  ];

  meta = with lib; {
    description = "Create and use COG mosaic based on mosaicJSON";
    homepage = "https://developmentseed.org/cogeo-mosaic/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
