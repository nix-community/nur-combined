{ lib
, python3Packages
, cmake
, openssl
, zlib
}:
python3Packages.buildPythonPackage rec {
  pname = "ssh2-python";
  version = "1.0.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-r4noDDID54KbJO6miOr1xeJ5BxrtGIIji09E7CFE58U=";
  };

  patches = [ ./fix-versioneer.patch ];
  
  nativeBuildInputs = with python3Packages; [ cmake setuptools ];
  buildInputs = [ openssl zlib ];
  propagatedBuildInputs = with python3Packages; [ cython ];
  cmakeDir = "../libssh2/libssh2";

  checkInputs = with python3Packages; [ pytest ];

  preBuild = ''
    cd ..
  '';

  doCheck = true;

  meta = with lib; {
    description = "Super fast SSH2 protocol library";
    homepage = "https://github.com/ParallelSSH/ssh2-python";
    license = licenses.lgpl2;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
