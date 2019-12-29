{ lib, buildPythonApplication, python, requests, gpxpy, gpxelevations }:

buildPythonApplication rec {
  pname = "gpxelevations";
  version = lib.substring 0 7 src.rev;
  src = gpxelevations;

  propagatedBuildInputs = [ requests gpxpy ];

  doCheck = false;
  #checkPhase = ''
  #  ${python.interpreter} -m unittest test
  #'';

  meta = with lib; {
    description = gpxelevations.description;
    homepage = "https://github.com/tkrajina/srtm.py";
    license = licenses.asl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [ sikmir ];
  };
}
