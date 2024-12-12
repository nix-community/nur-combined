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
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "mapbox";
    repo = "tilesets-cli";
    tag = "v${version}";
    hash = "sha256-ZAPoHtrUA+D1mjWGJ/YvErYmWiXMS+tsPG+CokB9Iy8=";
  };

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
