{ lib, stdenv, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "geojson-pydantic";
  version = "0.5.0";
  format = "flit";

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "geojson-pydantic";
    rev = version;
    hash = "sha256-ZAd4qLwQeAdOcwZ316Q/8VrsemuttzBlc0Qbwd6Nywo=";
  };

  nativeBuildInputs = with python3Packages; [ flit-core ];

  propagatedBuildInputs = with python3Packages; [
    pydantic shapely
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    description = "Pydantic data models for the GeoJSON spec";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
