{ lib, python3Packages, sources }:
let
  pname = "gpxelevations";
  date = lib.substring 0 10 sources.gpxelevations.date;
  version = "unstable-" + date;
in
python3Packages.buildPythonApplication {
  inherit pname version;
  src = sources.gpxelevations;

  propagatedBuildInputs = with python3Packages; [ requests gpxpy ];

  doCheck = false;
  #checkPhase = ''
  #  ${python3Packages.python.interpreter} -m unittest test
  #'';

  meta = with lib; {
    inherit (sources.gpxelevations) description homepage;
    license = licenses.asl20;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
