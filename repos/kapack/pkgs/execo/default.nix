{ lib, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "execo";
  version = "2.8.2";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-OO59TcPl1X5a7KjpIw/gAhKdy8GXeMihUrEjec7h3lo=";
  };

  meta = with lib; {
    description = "Execo";
    homepage = "https://gitlab.inria.fr/mimbert/execo";
    platforms = platforms.all;
    license = licenses.gpl3;
    broken = false;
    longDescription = "Execo";
  };
}
