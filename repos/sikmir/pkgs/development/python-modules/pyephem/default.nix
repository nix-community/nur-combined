{ lib, python3Packages, sources }:

python3Packages.buildPythonPackage {
  pname = "pyephem-unstable";
  version = lib.substring 0 10 sources.pyephem.date;

  src = sources.pyephem;

  meta = with lib; {
    inherit (sources.pyephem) description homepage;
    license = licenses.lgpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
