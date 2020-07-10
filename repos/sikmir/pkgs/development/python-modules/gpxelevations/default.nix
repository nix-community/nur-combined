{ lib, buildPythonApplication, python, requests, gpxpy, sources }:
let
  pname = "gpxelevations";
  date = lib.substring 0 10 sources.gpxelevations.date;
  version = "unstable-" + date;
in
buildPythonApplication {
  inherit pname version;
  src = sources.gpxelevations;

  propagatedBuildInputs = [ requests gpxpy ];

  doCheck = false;
  #checkPhase = ''
  #  ${python.interpreter} -m unittest test
  #'';

  meta = with lib; {
    inherit (sources.gpxelevations) description homepage;
    license = licenses.asl20;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
