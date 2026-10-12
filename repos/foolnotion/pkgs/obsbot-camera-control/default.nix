{ lib
, stdenv
, fetchFromGitHub
, cmake
, patchelf
, qt6
}:

stdenv.mkDerivation rec {
  pname = "obsbot-camera-control";
  version = "unstable-2026-09-11";

  src = fetchFromGitHub {
    owner = "aaronsb";
    repo = "obsbot-camera-control";
    rev = "main";
    hash = "sha256-V6zCrbfZqdCVQ//0+c/lJchMXuE40qk4psaiX0BA5y4=";
  };

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtmultimedia
    qt6.qtwayland
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ''${CMAKE_SOURCE_DIR}/bin)' 'set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ''${CMAKE_BINARY_DIR}/bin)' \
      --replace-fail 'set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ''${CMAKE_SOURCE_DIR}/bin)' 'set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ''${CMAKE_BINARY_DIR}/bin)' \
      --replace-fail 'set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ''${CMAKE_SOURCE_DIR}/bin)' 'set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ''${CMAKE_BINARY_DIR}/bin)'
  '';
  postInstall = ''
    install -Dm644 ../sdk/lib/libdev.so $out/lib/libdev.so
    patchelf --set-rpath "$out/lib" $out/bin/obsbot-camera-control $out/bin/obsbot-camera-control-cli
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/obsbot-gui $out/bin/obsbot-camera-control
    install -Dm755 bin/obsbot-cli $out/bin/obsbot-camera-control-cli
    install -Dm644 ../resources/icons/camera.svg \
      $out/share/icons/hicolor/scalable/apps/obsbot-camera-control.svg
    install -Dm644 ../obsbot-control.desktop \
      $out/share/applications/obsbot-camera-control.desktop
    substituteInPlace $out/share/applications/obsbot-camera-control.desktop \
      --replace-fail 'Exec=obsbot-gui' 'Exec=obsbot-camera-control' \
      --replace-fail 'Icon=obsbot-control' 'Icon=obsbot-camera-control'
    runHook postInstall
  '';

  meta = {
    description = "Linux control application for OBSBOT cameras";
    homepage = "https://github.com/aaronsb/obsbot-camera-control";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    mainProgram = "obsbot-camera-control";
  };
}
