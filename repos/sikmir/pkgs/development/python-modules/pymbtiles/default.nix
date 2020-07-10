{ lib, buildPythonPackage, pytest, sources }:
let
  pname = "pymbtiles";
  date = lib.substring 0 10 sources.pymbtiles.date;
  version = "unstable-" + date;
in
buildPythonPackage {
  inherit pname version;
  src = sources.pymbtiles;

  checkInputs = [ pytest ];
  checkPhase = "pytest";

  meta = with lib; {
    inherit (sources.pymbtiles) description homepage;
    license = licenses.isc;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
