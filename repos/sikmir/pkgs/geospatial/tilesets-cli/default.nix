{ lib, fetchFromGitHub, python3Packages, jsonseq, supermercado }:

python3Packages.buildPythonApplication rec {
  pname = "tilesets-cli";
  version = "1.7.1";

  src = fetchFromGitHub {
    owner = "mapbox";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-nAI5mwXlJ8JKUna+2dNwMnfEJuQqTrrXW10slNkjv9w=";
  };

  postPatch = "sed -i 's/~=.*\"/\"/' setup.py";

  propagatedBuildInputs = with python3Packages; [
    boto3
    click
    cligj
    requests
    requests-toolbelt
    jsonschema
    jsonseq
    mercantile
    supermercado
  ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  installCheckPhase = "$out/bin/tilesets --version | grep ${version} > /dev/null";

  meta = with lib; {
    description = "CLI for interacting with the Mapbox Tilesets API";
    homepage = "https://docs.mapbox.com/mapbox-tiling-service";
    license = licenses.bsd2;
    maintainers = [ maintainers.sikmir ];
  };
}
