{ lib, stdenv, fetchFromGitHub, python3Packages, testers, morecantile }:

python3Packages.buildPythonPackage rec {
  pname = "morecantile";
  version = "5.2.2";
  pyproject = true;
  disabled = python3Packages.pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "morecantile";
    rev = version;
    hash = "sha256-Y0KUsI0OjkgEjEJsMTwchcQG0LEOEzj7YwN5F+eUb8I=";
  };

  nativeBuildInputs = with python3Packages; [ flit ];

  propagatedBuildInputs = with python3Packages; [ attrs pydantic pyproj ];

  nativeCheckInputs = with python3Packages; [ mercantile pytestCheckHook rasterio ];

  passthru.tests.version = testers.testVersion {
    package = morecantile;
  };

  meta = with lib; {
    description = "Construct and use map tile grids in different projection";
    homepage = "https://developmentseed.org/morecantile/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
