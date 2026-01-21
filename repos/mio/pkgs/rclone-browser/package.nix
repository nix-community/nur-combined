{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  cmake,
  qt6,
}:

stdenv.mkDerivation rec {
  pname = "rclone-browser";
  version = "1.9.0-unstable-20250408";

  src = fetchFromGitHub {
    owner = "kRHYME7";
    repo = "RcloneBrowser";
    rev = "66a8a06cc1f55a5a997540fb61a4310eebfad9bc";
    hash = "sha256-q2fwpseRAEgN10RWODHI03YCXzLlPmbgmPfllfSenDA=";
  };

  patches = [
    ./0001-default-to-vfs-cache-mode-full.patch
  ];

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error";

  buildInputs = [ qt6.qtbase ];

  meta = {
    changelog = "https://github.com/kapitainsky/RcloneBrowser/blob/${src.tag}/CHANGELOG.md";
    homepage = "https://github.com/kapitainsky/RcloneBrowser";
    description = "Graphical Frontend to Rclone written in Qt";
    mainProgram = "rclone-browser";
    license = lib.licenses.unlicense;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
