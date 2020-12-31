{ stdenv
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
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "UnoconvUI";
    rev = "df87c0222045599bc467fef996e6dcadf41b8ca5";
    sha256 = "05jkapp22rdvliaf29sv4ywpy8cpi5p6nv2wkkwwi0qbmcbdqqw2";
  };

  # src = ./src.tar.gz;

  nativeBuildInputs = [ qmake qttools librsvg ];
  propagatedBuildInputs = [ qtquickcontrols2 ];
  buildInputs = [ qtbase ];

  installFlags = [ "INSTALL_ROOT=$(out)" ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "MS Office files conversion client for the Unoconv Web Service";
    license = licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/UnoconvUI";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}

