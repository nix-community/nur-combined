{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "supermercado";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "mapbox";
    repo = "supermercado";
    rev = "44841a07adff32665fae736f9ba7df8c7b24ac44";
    hash = "sha256-k2S1aOHQEJq//4mdWZ5GhJQJjKqJuDbBztoHi373s6w=";
  };

  propagatedBuildInputs = with python3Packages; [ click-plugins rasterio mercantile numpy ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    description = "Supercharger for mercantile";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
