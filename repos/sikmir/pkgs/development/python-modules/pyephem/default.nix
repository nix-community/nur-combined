{ lib, buildPythonPackage, pyephem }:

buildPythonPackage rec {
  pname = "pyephem";
  version = lib.substring 0 7 src.rev;
  src = pyephem;

  meta = with lib; {
    description = pyephem.description;
    homepage = pyephem.homepage;
    license = licenses.lgpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
