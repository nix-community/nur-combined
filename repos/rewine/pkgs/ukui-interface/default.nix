{ lib
, stdenv
, fetchFromGitea
, autoreconfHook
, pkg-config
, wrapQtAppsHook
, qtbase
, glib
, libxcrypt
, iniparser
}:

stdenv.mkDerivation rec {
  pname = "ukui-interface";
  version = "1.0.3";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "wine";
    repo = pname;
    rev = "7007385378f8755131bb9a2dbe933f329175e120";
    sha256 = "sha256-+Ln2TDo0PIWbp5Bs58G92VCBApSiLXUWE1mHi5iwPuw=";
  };

  postPatch = ''
    substituteInPlace src/common/kylin-com{4c.c,4cxx.cpp} \
      --replace "iniparser/iniparser.h" "iniparser.h"

    for file in $(grep -rl "/usr")
    do
      substituteInPlace $file \
        --replace "/usr" "$out"
    done
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    glib
    libxcrypt
    iniparser
  ];

  enableParallelBuilding = false;

  #qmakeFlags = [
  #  "peony-qt.pro"
  #];

  meta = with lib; {
    description = "The File Manager Application of UKUI";
    homepage = "https://github.com/ukui/peony";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ rewine ];
  };
}

