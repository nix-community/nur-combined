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
  version = "2020-12-30";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "UnoconvUI";
    rev = "6a3d9ecf2be3739920d5514f75b4ab2539ee66a6";
    sha256 = "1hzj8l4pds5zbw128cryynmk0cwnfj1bsadgv8r16wcghaxrcxyj";
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

