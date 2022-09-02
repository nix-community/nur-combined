{ lib, stdenv, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "geojson-pydantic";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "geojson-pydantic";
    rev = version;
    hash = "sha256-WTsusDLTmZUAX5BpXHpKPe19nmort45Mx6D1wVYKaGw=";
  };

  propagatedBuildInputs = with python3Packages; [
    pydantic
  ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    description = "Pydantic data models for the GeoJSON spec";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
