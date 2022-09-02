{ lib, fetchFromGitHub, python3Packages, pymbtiles }:

python3Packages.buildPythonApplication rec {
  pname = "tpkutils";
  version = "2021-02-10";

  src = fetchFromGitHub {
    owner = "consbio";
    repo = "tpkutils";
    rev = "5f3694451a1759548af579b689f478cefc633252";
    hash = "sha256-6eEDRGpBP27jT2KAg7EtsUm9wxEYrlKa8EkB/7/1JWc=";
  };

  propagatedBuildInputs = with python3Packages; [ mercantile pymbtiles setuptools six ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    description = "ArcGIS Tile Package Utilities";
    inherit (src.meta) homepage;
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
  };
}
