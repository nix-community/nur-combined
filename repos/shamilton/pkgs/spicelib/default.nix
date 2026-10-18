{ lib
, python3Packages
, clipin
}:

python3Packages.buildPythonPackage rec {
  pname = "spicelib";
  version = "1.6.4";

  pyproject = true;

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-mVZ5u6xB2cCUFSXdEvCKADymZEQXUifCxyowxkba4fc=";
  };

  build-system = with python3Packages; [
    poetry-core
  ];

  dependencies = with python3Packages; [
    numpy
    scipy
    psutil
    matplotlib
    clipin
  ];

  doCheck = false;

  meta = with lib; {
    description = "Python tools to automate SPICE simulations";
    homepage = "https://github.com/nunobrum/spicelib";
    license = licenses.gpl3Only;
    maintainers = [
      "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>"
    ];
    platforms = platforms.linux;
  };
}
