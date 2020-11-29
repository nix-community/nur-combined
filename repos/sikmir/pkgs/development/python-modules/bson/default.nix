{ lib, python3Packages, sources }:

python3Packages.buildPythonPackage {
  pname = "bson-unstable";
  version = lib.substring 0 10 sources.bson.date;

  src = sources.bson;

  propagatedBuildInputs = with python3Packages; [ python-dateutil six ];

  meta = with lib; {
    inherit (sources.bson) description homepage;
    license = with licenses; [ bsd3 asl20 ];
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
