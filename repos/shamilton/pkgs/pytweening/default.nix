{ lib
, python3Packages
, fetchFromGitHub 
}:

python3Packages.buildPythonPackage rec {
  pname = "pytweening";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "asweigart";
    repo = "pytweening";
    rev = "20d74368e53dc7d0f77c810b624b2c90994f099d";
    sha256 = "10d2wcpyilgnjj7c7klkd5s6lr5hxyqa2ww558jm0jvfhdxcdamm";
  };

  doCheck = false;

  meta = with lib; {
    description = "A set of tweening / easing functions implemented in Python";
    license = licenses.bsd3;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
