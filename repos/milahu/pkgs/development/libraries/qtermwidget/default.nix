# see also
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/desktops/lxqt/qtermwidget/default.nix

{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  qt6,
  lxqt-build-tools,
}:

stdenv.mkDerivation rec {
  pname = "qtermwidget";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "qtermwidget";
    rev = version;
    hash = "sha256-tzgHNGB063rgFB15lHTKQplNhwJZtrRprUhMm5H62AA=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qttools # Qt6LinguistTools
    lxqt-build-tools
  ];

  dontWrapQtApps = true;

  meta = {
    description = "The terminal widget for QTerminal";
    homepage = "https://github.com/lxqt/qtermwidget";
    changelog = "https://github.com/lxqt/qtermwidget/blob/${src.rev}/CHANGELOG";
    license = with lib.licenses; [ bsd3 lgpl2Only ];
    maintainers = with lib.maintainers; [ ];
    mainProgram = "qtermwidget";
    platforms = lib.platforms.all;
  };
}
