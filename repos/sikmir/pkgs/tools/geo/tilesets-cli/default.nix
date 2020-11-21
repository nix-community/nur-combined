{ lib, python3Packages, jsonseq, mercantile, supermercado, sources }:

python3Packages.buildPythonApplication {
  pname = "tilesets-cli-unstable";
  version = lib.substring 0 10 sources.tilesets-cli.date;

  src = sources.tilesets-cli;

  propagatedBuildInputs = with python3Packages; [
    boto3 click cligj
    requests requests-toolbelt
    jsonschema jsonseq
    mercantile supermercado
  ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    inherit (sources.tilesets-cli) description homepage;
    license = licenses.bsd2;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
