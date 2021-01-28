{ lib, python3Packages, thinplatespline, sources }:

python3Packages.buildPythonPackage {
  pname = "maprec";
  version = lib.substring 0 10 sources.maprec.date;

  src = sources.maprec;

  patches = [ ./python3.patch ];

  postPatch = "2to3 -n -w maprec/*.py";

  propagatedBuildInputs = with python3Packages; [ pyyaml pyproj thinplatespline ];

  doCheck = false;

  pythonImportsCheck = [ "maprec" ];

  meta = with lib; {
    inherit (sources.maprec) description homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
