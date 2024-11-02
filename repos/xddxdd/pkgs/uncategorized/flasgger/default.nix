{
  lib,
  sources,
  python3Packages,
}:
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

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Easy OpenAPI specs and Swagger UI for your Flask API";
    homepage = "http://flasgger.pythonanywhere.com/";
    license = with lib.licenses; [ mit ];
  };
}
