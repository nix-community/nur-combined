{ lib, python3Packages, sources }:

python3Packages.buildPythonPackage {
  pname = "pymbtiles-unstable";
  version = lib.substring 0 10 sources.pymbtiles.date;

  src = sources.pymbtiles;

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    inherit (sources.pymbtiles) description homepage;
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
  };
}
