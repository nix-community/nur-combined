# FIXME?
# -- Got nothing from: /nix/store/l9kvcx3wna1bla7xpy1629hawjqmna4y-qtbase-6.9.0/bin/qtpaths --query "QT_INSTALL_CONFIGURATION"
# -- Unable to autodetect LXQT_ETC_XDG_DIR. LXQT_ETC_XDG_DIR will be set to '/etc/xdg'

{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  qt6,
}:

stdenv.mkDerivation rec {
  pname = "lxqt-build-tools";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "lxqt-build-tools";
    rev = version;
    hash = "sha256-dewsmkma8QHgb3LzRGvfntI48bOaFFsrEDrOznaC8eg=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    qt6.qtbase
  ];

  dontWrapQtApps = true;

  meta = {
    description = "Various packaging tools and scripts for LXQt applications";
    homepage = "https://github.com/lxqt/lxqt-build-tools";
    changelog = "https://github.com/lxqt/lxqt-build-tools/blob/${src.rev}/CHANGELOG";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ];
    # mainProgram = "lxqt-build-tools";
    platforms = lib.platforms.all;
  };
}
