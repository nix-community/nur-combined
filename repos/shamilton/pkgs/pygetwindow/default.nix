{ lib
, python3Packages
, pyrect
}:

python3Packages.buildPythonPackage rec {
  pname = "PyGetWindow";
  version = "0.0.9";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "1256s0nj9w7vyzv29klhi9lw25s07047fw9dhg6hbcyjwxal728p";
  };

  propagatedBuildInputs = with python3Packages; [
    pyrect
  ];

  doCheck = false;

  meta = with lib; {
    description = "Simple, module for obtaining GUI information on applications' windows";
    homepage = "https://github.com/asweigart/pygetwindow";
    license = licenses.bsd3;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
