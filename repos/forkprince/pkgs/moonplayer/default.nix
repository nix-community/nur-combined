{
  fetchFromGitHub,
  python3,
  stdenv,
  ffmpeg,
  cmake,
  wget,
  curl,
  mpv,
  qt6,
  lib,
}:
stdenv.mkDerivation rec {
  pname = "moonplayer";
  version = "4.3";

  src = fetchFromGitHub {
    owner = "coslyk";
    repo = "moonplayer";
    rev = "v${version}";
    hash = "sha256-SckSTwGcnTItd9M3fkzsCdg6Ocv/CtXBxVi08CW4l/c=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
    cmake
  ];

  buildInputs = [
    qt6.qtdeclarative
    qt6.qttools
    qt6.qtbase
    python3
    ffmpeg
    wget
    curl
    mpv
  ];

  cmakeFlags = [
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    "-DCMAKE_PREFIX_PATH=${qt6.qtbase}"
  ];

  meta = {
    description = "Video player that can play online videos from YouTube, Bilibili etc";
    homepage = "https://github.com/coslyk/moonplayer";
    license = lib.licenses.gpl3Only;
    maintainers = ["Prinky"];
    mainProgram = "moonplayer";
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [fromSource];
  };
}
