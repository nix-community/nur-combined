{ lib
, fetchFromGitHub
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "nix-bisect";
  version = "2020-09-22";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "nix-bisect";
    rev = "9f5d8b36e97e723460e5e3ba3fc4e8102adc79a1";
    sha256 = "0gfq9vglwgh8jjb5il9nkrspz1hpyav2x742152p4zckvwd5n9dm";
  };

  propagatedBuildInputs = with python3Packages; [
    appdirs
    numpy
    pexpect
  ];

  doCheck = false;

  meta = with lib; {
    description = "Bisect nix builds";
    homepage = "https://github.com/SCOTT-HAMILTON/nix-bisect";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
