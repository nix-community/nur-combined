{ lib, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "execo";
  version = "2.6.8";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-xkAMVQxAy9zx2P6R8I/Xz7afQJP0c0I8hddrKeEcPF4=";
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
