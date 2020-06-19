{ lib
, buildPythonPackage
, fetchFromGitHub
, parallel-ssh
, libssh2
, merge-keepass
, pykeepass
, click
}:
let 
  pyModuleDeps = [
    parallel-ssh
    pykeepass
    click
    merge-keepass
  ];
in
buildPythonPackage rec {
  pname = "sync-database";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "sync-database";
    rev = "master";
    sha256 = "0mflbr6mcwl2544scnhpjnyilxnhqbdfg97b10lmwkxhv2j2b9w6";
  };

  buildInputs = pyModuleDeps;
  propagatedBuildInputs = pyModuleDeps ++ [ libssh2 ];
  
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
