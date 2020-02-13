{ lib, buildPythonApplication, python, requests, gpxpy, sources }:

buildPythonApplication rec {
  pname = "gpxelevations";
  version = lib.substring 0 7 src.rev;
  src = sources.gpxelevations;

  propagatedBuildInputs = [ requests gpxpy ];

  doCheck = false;
  #checkPhase = ''
  #  ${python.interpreter} -m unittest test
  #'';

  meta = with lib; {
    inherit (src) description homepage;
    license = licenses.asl20;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
