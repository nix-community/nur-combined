{ lib, buildPythonApplication, python, lxml, gpxpy }:

buildPythonApplication rec {
  pname = "gpxpy";
  version = lib.substring 0 7 src.rev;
  src = gpxpy;

  propagatedBuildInputs = [ lxml ];

  checkPhase = ''
    ${python.interpreter} -m unittest test
  '';

  meta = with lib; {
    description = gpxpy.description;
    homepage = gpxpy.homepage;
    license = licenses.asl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [ sikmir ];
  };
}
