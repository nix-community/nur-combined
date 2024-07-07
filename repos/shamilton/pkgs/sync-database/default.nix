{ lib
, python3Packages
, fetchFromGitHub
, parallel-ssh
, libssh2
, merge-keepass
, nix-gitignore
}:

python3Packages.buildPythonPackage rec {
  pname = "sync-database";
  version = "2023-07-11";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "sync-database";
    rev = "a4c3dd46ab634f1764bb694734e77cccb858ba0d";
    sha256 = "sha256-XT3up7zUPqw0RGTMy0ceF6N7SVWLyEe18q+ZN3HZwWs=";
  };

  propagatedBuildInputs = with python3Packages; [
    setuptools
    libssh2
    parallel-ssh
    merge-keepass
    pykeepass
    click
  ];
  
  doCheck = false;
  
  makeWrapperArgs = [
    "--set LD_LIBRARY_PATH \"${libssh2}/lib\""
  ];

  meta = with lib; {
    description = "Keepass databases synching script to ssh servers and phone";
    homepage = "https://github.com/SCOTT-HAMILTON/sync-database";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
