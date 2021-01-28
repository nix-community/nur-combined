{ lib, python3Packages, maprec, sources }:

python3Packages.buildPythonPackage {
  pname = "ozi_map";
  version = lib.substring 0 10 sources.ozi-map.date;

  src = sources.ozi-map;

  postPatch = "2to3 -n -w ozi_map/*.py";

  propagatedBuildInputs = with python3Packages; [ maprec pyproj ];

  doCheck = false;

  pythonImportsCheck = [ "ozi_map" ];

  meta = with lib; {
    inherit (sources.ozi-map) description homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
