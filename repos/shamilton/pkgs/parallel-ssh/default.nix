{ lib
, python3Packages
, ssh-python
, ssh2-python
, libssh2
}:

python3Packages.buildPythonPackage rec {
  pname = "parallel-ssh";
  version = "2.5.4";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "01r8ajq2vic6l9rihailv5a100gwf6k4mswbmaqyrjr39h0pg571";
  };
  
  propagatedBuildInputs = with python3Packages; [
    gevent
    paramiko
    ssh-python
    ssh2-python
    libssh2
  ];
  
  doCheck = true;

  meta = with lib; {
    description = "Asynchronous parallel SSH client library";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
