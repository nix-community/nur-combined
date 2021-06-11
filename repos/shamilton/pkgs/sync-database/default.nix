{ lib
, buildPythonPackage
, fetchFromGitHub
, parallel-ssh
, libssh2
, merge-keepass
, pykeepass
, click
}:

buildPythonPackage rec {
  pname = "sync-database";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "sync-database";
    rev = "20431f337db65ed628e5585fa55435546ed324ff";
    sha256 = "102yn8ipwzsz08nrdjhc005f270wj41859jh1879d0qv6q6nb1pw";
  };

  propagatedBuildInputs = [ libssh2 parallel-ssh merge-keepass pykeepass click ];
  
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
