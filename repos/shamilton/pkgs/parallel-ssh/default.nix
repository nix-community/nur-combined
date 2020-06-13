{ lib
, buildPythonPackage
, setuptools
, fetchPypi
, paramiko
, gevent
, ssh2-python
, openssh
, libssh2
}:
let 
  pyModuleDeps = [
    # libkeepass
    setuptools
    gevent
    paramiko
    ssh2-python
  ];
in
buildPythonPackage rec {
  pname = "parallel-ssh";
  version = "1.9.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0s8359f8mr3lqb3yi2cv65hdl9q97rrfxrwp4ib1cdf7kf6cy7yv";
  };
  
  buildInputs = pyModuleDeps;
  propagatedBuildInputs = pyModuleDeps ++ [ libssh2 ];
  
  # Checks fails with libssh2.so.1 missing, while libssh2 in checkInputs
  doCheck = false;

  meta = with lib; {
    description = "Keepass Databases Merging script";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
