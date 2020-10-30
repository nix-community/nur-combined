{ lib, python3Packages, jsonseq, mercantile, supermercado, sources }:
let
  pname = "tilesets-cli";
  date = lib.substring 0 10 sources.tilesets-cli.date;
  version = "unstable-" + date;
in
python3Packages.buildPythonApplication {
  inherit pname version;
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
