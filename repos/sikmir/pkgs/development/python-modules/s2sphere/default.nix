{ lib, python3Packages, sources }:

python3Packages.buildPythonPackage {
  pname = "s2sphere-unstable";
  version = lib.substring 0 10 sources.s2sphere.date;

  src = sources.s2sphere;

  propagatedBuildInputs = with python3Packages; [ future ];

  doCheck = false;

  pythonImportCheck = [ "s2sphere" ];

  meta = with lib; {
    inherit (sources.s2sphere) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
