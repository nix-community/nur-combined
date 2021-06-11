{ lib
, buildPythonPackage
, fetchFromGitHub
, parallel-ssh
, libssh2
, merge-keepass
, pykeepass
, click
, setuptools
}:

buildPythonPackage rec {
  pname = "sync-database";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "sync-database";
    rev = "cd57461009298229762b27e5ae3bf6100b6196cb";
    sha256 = "0m9gac1b6haaifi69lwybq1hlp631jbxyj79ccfxchfjxanhjhrr";
  };

  propagatedBuildInputs = [ setuptools libssh2 parallel-ssh merge-keepass pykeepass click ];
  
  doCheck = false;
  
  makeWrapperArgs = [
    "--set LD_LIBRARY_PATH \"${libssh2}/lib\""
  ];

  meta = with lib; {
    description = "Keepass databases synching script to ssh servers and phone";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
