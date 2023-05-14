{ lib
, stdenv
, fetchFromGitea
, qmake
, qttools
, pkg-config
, wrapQtAppsHook
, dconf
, qtx11extras
, poppler
, gsettings-qt
, udisks2
, libnotify
, libcanberra
, kwindowsystem
, ukui-interface
}:

stdenv.mkDerivation rec {
  pname = "peony";
  version = "4.0.0";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "wine";
    repo = pname;
    rev = "740dd4462358522d6829635b8b6c71472b176033";
    sha256 = "sha256-GCTP1P3bX6+sYGkJ5dKfoCq9qz7MYXyG0ne6usQcqUU=";
  };

  patches = [
    ./0001-fix-KDKGetOSRelease-not-found-without-kylin-common.patch
  ];

  postPatch = ''
    for file in $(grep -rl "/usr")
    do
      substituteInPlace $file \
        --replace "/usr" "$out"
    done
  '';

  nativeBuildInputs = [
    qmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    dconf
    qtx11extras
    poppler
    gsettings-qt
    udisks2
    libnotify
    libcanberra
    kwindowsystem
    ukui-interface
  ];

  enableParallelBuilding = false;

  qmakeFlags = [
  #  "peony-qt.pro"
  ];

  meta = with lib; {
    description = "The File Manager Application of UKUI";
    homepage = "https://github.com/ukui/peony";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ rewine ];
  };
}

