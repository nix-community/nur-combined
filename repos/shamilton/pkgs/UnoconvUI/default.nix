{ stdenv
, lib
, fetchFromGitHub
, mkDerivation
, qmake
, qtbase
, qttools
, qtquickcontrols2
, librsvg
}:

mkDerivation rec {
  pname = "UnoconvUI";
  version = "2021-06-20";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "UnoconvUI";
    rev = "7c3c71dd00224e249ae99165b9e2ae8d80502a90";
    sha256 = "1wjdv10bhc1nbyzbfwmz1fbv63vjabjdmmnjjfv8avp672mlc6wa";
  };

  nativeBuildInputs = [ qmake qttools librsvg ];
  propagatedBuildInputs = [ qtquickcontrols2 ];
  buildInputs = [ qtbase ];

  installFlags = [ "INSTALL_ROOT=$(out)" ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "MS Office files conversion client for the Unoconv Web Service";
    license = licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/UnoconvUI";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}

