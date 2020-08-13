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
let 
  pyModuleDeps = with python38Packages; [
    cython
  ];
in
buildPythonPackage rec {
  pname = "ssh2-python";
  version = "0.17.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0kfs0yv2pfz3kklmvaapgsz593r2l1nm2qzmci0vvlq13jn1qf38";
  };

  
  nativeBuildInputs = [ breakpointHook cmake setuptools ];
  cmakeDir = "../libssh2";

  buildInputs = pyModuleDeps ++ [ openssl zlib ];
  propagatedBuildInputs = pyModuleDeps;

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
