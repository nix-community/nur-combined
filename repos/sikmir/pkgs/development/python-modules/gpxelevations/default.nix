{ lib, buildPythonApplication, python, requests, gpxpy, sources }:

buildPythonApplication {
  pname = "gpxelevations";
  version = lib.substring 0 7 sources.gpxelevations.rev;
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
