{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,

  qt6,
  zju-connect,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ez4connect";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "chenx-dust";
    repo = "EZ4Connect";
    rev = "v${finalAttrs.version}";
    hash = "sha256-sJgmO6+VRQARiQtalg+Q5rIRwF/iMZ0rxHvREdMv6dM=";
  };

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtsvg
    qt6.qt5compat
    qt6.qtwebengine
  ];

  qtWrapperArgs = [ "--prefix" "PATH" ":" "${lib.makeBinPath [ zju-connect ]}" ];

  meta = {
    description = "改进的 ZJU-Connect 图形界面";
    homepage = "https://github.com/chenx-dust/EZ4Connect";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ hhr2020 ];
    mainProgram = "EZ4Connect";
    platforms = lib.platforms.all;
  };
})
