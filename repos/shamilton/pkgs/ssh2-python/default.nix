{ lib
, python3Packages
, cmake
, openssl
, zlib
}:
python3Packages.buildPythonPackage rec {
  pname = "ssh2-python";
  version = "0.26.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "17llrzzmsfdd2sv4mhvx40azd28yihay33qspncvrlhjq68i4mgq";
  };
  
  nativeBuildInputs = with python3Packages; [ cmake setuptools ];
  buildInputs = [ openssl zlib ];
  propagatedBuildInputs = with python3Packages; [ cython ];
  cmakeDir = "../libssh2";

  checkInputs = with python3Packages; [ pytest ];

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
