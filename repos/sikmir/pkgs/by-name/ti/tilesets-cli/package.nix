{
  lib,
  fetchFromGitHub,
  python3Packages,
  jsonseq,
  supermercado,
  testers,
  tilesets-cli,
}:

python3Packages.buildPythonApplication rec {
  pname = "tilesets-cli";
  version = "1.13.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mapbox";
    repo = "tilesets-cli";
    tag = "v${version}";
    hash = "sha256-9IGJ3jhw2U5vZl9dG0ourxFgKV+QRf6JXT6nmvuTx7A=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    boto3
    click
    cligj
    numpy
    requests
    requests-toolbelt
    jsonschema
    jsonseq
    mercantile
    geojson
  ];

  pythonRelaxDeps = true;

  doCheck = false;
  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    supermercado
  ];

  passthru.tests.version = testers.testVersion { package = tilesets-cli; };

  meta = {
    description = "CLI for interacting with the Mapbox Tilesets API";
    homepage = "https://docs.mapbox.com/mapbox-tiling-service";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "tilesets";
  };
}
