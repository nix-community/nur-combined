{ lib, python3Packages, sources }:
let
  pname = "pymbtiles";
  date = lib.substring 0 10 sources.pymbtiles.date;
  version = "unstable-" + date;
in
python3Packages.buildPythonPackage {
  inherit pname version;
  src = sources.pymbtiles;

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    inherit (sources.pymbtiles) description homepage;
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
