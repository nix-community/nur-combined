{ lib
, python3Packages
, fetchFromGitHub 
}:

python3Packages.buildPythonPackage rec {
  pname = "pytweening";
  version = "2024-02-20";

  src = fetchFromGitHub {
    owner = "asweigart";
    repo = "pytweening";
    rev = "c622929950db00a8364bc26b836e6606c4d62614";
    sha256 = "sha256-d38NingNX+Dwc1GUAEgqEViQCyiRWEQGvy5d1T30D1k=";
  };

  doCheck = false;

  meta = with lib; {
    description = "A set of tweening / easing functions implemented in Python";
    homepage = "https://github.com/asweigart/pytweening";
    license = licenses.bsd3;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
