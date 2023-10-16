{ lib
, stdenv
, fetchgit
, meson
, pkg-config
, wlroots
}:

stdenv.mkDerivation rec {
  pname = "kylin-wayland-compositor";
  version = "1.0.0";

  src = fetchgit {
    url = "https://gitee.com/openKylin/kylin-wayland-compositor.git";
    rev = "e9999782ed5d219456f3dcacbc1b04448aceb2e8";
    hash = "sha256-T7x2peXKHjfRxKjAb2dOsAbRlqsbty4WrCflvC7EdOs=";
  };

  patches = [
  ];

  postPatch = ''
    for file in $(grep -rl "/usr")
    do
      substituteInPlace $file \
        --replace "/usr" "$out"
    done
  '';

  nativeBuildInputs = [
    meson
    pkg-config
  ];

  buildInputs = [
    wlroots
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

