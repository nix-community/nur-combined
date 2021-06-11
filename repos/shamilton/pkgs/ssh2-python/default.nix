{ lib
, buildPythonPackage
, fetchPypi
, python38Packages
, cmake
, openssl
, zlib
, cython
, setuptools
, pytest
, breakpointHook
}:
buildPythonPackage rec {
  pname = "ssh2-python";
  version = "0.26.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "17llrzzmsfdd2sv4mhvx40azd28yihay33qspncvrlhjq68i4mgq";
  };
  
  nativeBuildInputs = [ breakpointHook cmake setuptools ];
  buildInputs = [ openssl zlib ];
  propagatedBuildInputs = [ cython ];
  cmakeDir = "../libssh2";

  checkInputs = [ pytest ];

  preBuild = ''
    cd ..
  '';

  doCheck = true;

  meta = with lib; {
    description = "Super fast SSH2 protocol library";
    license = licenses.lgpl2;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
