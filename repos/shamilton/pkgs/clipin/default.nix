
{ lib
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "clipin";
  version = "1.0.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-+CBM/rWNuG1Y4ZeHtopPoTY9m8Gw0wclQIGZZzhQ5Pk=";
  };

  pyproject = true;

  build-system = with python3Packages; [
    poetry-core
  ];

  doCheck = false;

  meta = with lib; {
    description = "Pure-Python clipboard utility supporting multiple formats";
    homepage = "https://github.com/nunobrum/clipin";
    license = licenses.mit;
    maintainers = [
      "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>"
    ];
    platforms = platforms.linux;
  };
}
