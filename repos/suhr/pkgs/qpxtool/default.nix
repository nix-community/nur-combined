{ lib
, stdenv
, fetchFromGitHub
, libpng
, qt6
}:

stdenv.mkDerivation rec {
  pname = "qpxtool";
  version = "0.8.1-pl8";

  src = fetchFromGitHub {
    owner = "speed47";
    repo = "qpxtool";
    rev = "v${version}";
    hash = "sha256-baljQxske1sUeEERg2xKwz4LtrEuK2bgvaqod762hhc="; # replace with real hash
  };

  patches = [ ./patches/lrelease.patch ];

  postPatch = ''
    sed -i 's/-m 4755/-m 755/g' console/cdvdcontrol/Makefile \
                                console/f1tattoo/Makefile \
                                console/qscan/Makefile
  '';

  nativeBuildInputs = [
    qt6.qttools
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    libpng
    qt6.qtbase
  ];

  configureFlags = [
    "--lrelease=${lib.getDev qt6.qttools}/bin/lrelease"
  ];

  meta = with lib; {
    description = "Access to all available Quality Checks (Q-Checks) on written and blank media (speed47 fork)";
    homepage = "https://github.com/speed47/qpxtool";
    license = licenses.gpl2Plus;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
