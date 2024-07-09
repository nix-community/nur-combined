{ lib
, python3Packages
, ssh2-python
, libssh2
}:

python3Packages.buildPythonPackage rec {
  pname = "parallel-ssh";
  version = "2.12.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-viwG7odlJz0gTgD4Kvri2s5e6678U0PR38ZFE2QhYeA=";
  };

  patches = [ ./fix-versioneer.patch ];
  
  propagatedBuildInputs = with python3Packages; [
    gevent
    paramiko
    ssh2-python
    libssh2
  ];
  
  doCheck = false;

  meta = with lib; {
    description = "Asynchronous parallel SSH client library";
    homepage = "https://parallel-ssh.org/";
    license = licenses.lgpl21Plus;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
