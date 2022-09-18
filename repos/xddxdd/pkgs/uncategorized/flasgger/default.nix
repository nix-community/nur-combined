{ lib
, sources
, python3Packages
, ...
} @ args:

python3Packages.buildPythonPackage rec {
  inherit (sources.flasgger) pname version src;

  propagatedBuildInputs = with python3Packages; [
    flask
    pyyaml
    jsonschema
    mistune
    six
  ];

  doCheck = false;

  meta = with lib; {
    description = "Easy OpenAPI specs and Swagger UI for your Flask API";
    homepage = "http://flasgger.pythonanywhere.com/";
    license = with licenses; [ mit ];
  };
}
