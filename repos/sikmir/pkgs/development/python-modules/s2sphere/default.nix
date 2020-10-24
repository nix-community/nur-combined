{ lib, python3Packages, sources }:
let
  pname = "s2sphere";
  date = lib.substring 0 10 sources.s2sphere.date;
  version = "unstable-" + date;
in
python3Packages.buildPythonPackage {
  inherit pname version;
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
