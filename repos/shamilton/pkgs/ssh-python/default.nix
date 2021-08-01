{ lib
, python3Packages
, cmake
, zlib
, openssl
}:

python3Packages.buildPythonPackage rec {
  pname = "ssh-python";
  version = "0.9.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "0sm9hqcc2ndbnq7kak1v1949pzym5fsvzfhfp3knil1013a7i1zk";
  };
  
  nativeBuildInputs = [ cmake ];
  buildInputs = [ zlib openssl ];
  cmakeDir = "../libssh";

  preBuild = ''
    cd ..
  '';

  doCheck = true;

  meta = with lib; {
    description = "Bindings for libssh C library";
    license = licenses.lgpl21Plus;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
