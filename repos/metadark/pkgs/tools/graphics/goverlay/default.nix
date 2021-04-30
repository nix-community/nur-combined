{ lib
, stdenv
, fetchFromGitHub
, fpc
, lazarus-qt
, qt5
, libX11
, libqt5pas
}:

stdenv.mkDerivation rec {
  pname = "goverlay";
  version = "0.5";

  src = fetchFromGitHub {
    owner = "benjamimgois";
    repo = pname;
    rev = version;
    hash = "sha256-qS0GY2alUBfkmT20oegGpkhVkK+ZOUkJCPSV/wt0ZUA=";
  };

  nativeBuildInputs = [ fpc lazarus-qt qt5.wrapQtAppsHook ];
  buildInputs = [ libX11 libqt5pas ];

  NIX_LDFLAGS = "--as-needed -rpath ${lib.makeLibraryPath buildInputs}";

  postPatch = ''
    substituteInPlace Makefile \
      --replace 'prefix = /usr/local' "prefix = $out"
  '';

  buildPhase = ''
    HOME=$(mktemp -d) lazbuild --lazarusdir=${lazarus-qt}/share/lazarus -B goverlay.lpi
  '';

  # Force xcb since libqt5pas doesn't support Wayland
  # See https://github.com/benjamimgois/goverlay/issues/107
  qtWrapperArgs = [
    "--set QT_QPA_PLATFORM xcb"
  ];

  meta = with lib; {
    description = "An opensource project that aims to create a Graphical UI to help manage Linux overlays";
    homepage = "https://github.com/benjamimgois/goverlay";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ metadark ];
    platforms = platforms.linux;
  };
}
