{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  qt6Packages,
  rapidjson,
  SDL2,
  glslang,
  libGL,
  alsa-lib,
  libpulseaudio,
  libx11,
  pipewire,
  spirv-tools,
  vulkan-headers,
  vulkan-loader,
  wayland,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "panda3ds";
  version = "0.9-unstable-2026-10-04";

  src = fetchFromGitHub {
    owner = "wheremyfoodat";
    repo = "Panda3DS";
    rev = "92e53d26b898eb89d865f8407460900a88e7c0fa";
    hash = "sha256-N7HmIVY5DSZ23YDthTzLDWbmPXnqx/qM5on8FHh8ONk=";
    # 27 submodules, and third_party/discord-rpc is the only one whose CMake
    # fetches anything at configure time; postPatch takes that out of play.
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    SDL2
    glslang
    libGL
    libx11
    qt6Packages.qtbase
    qt6Packages.qtwayland
    rapidjson
    spirv-tools
    vulkan-headers
    vulkan-loader
    wayland
  ];

  # discord-rpc probes thirdparty/ for the rapidjson tree and file(DOWNLOAD)s
  # v1.1.0 when it is absent, with no STATUS check, so a sandboxed build fails
  # later on the missing header rather than here. The name is one it searches for.
  postPatch = ''
    mkdir -p third_party/discord-rpc/thirdparty
    ln -s ${rapidjson} third_party/discord-rpc/thirdparty/rapidjson-1.1.0
  '';

  cmakeFlags = [
    (lib.cmakeBool "ENABLE_QT_GUI" true)
    (lib.cmakeBool "ENABLE_USER_BUILD" true)
    (lib.cmakeBool "ENABLE_VULKAN" true)
    (lib.cmakeBool "ENABLE_WAYLAND" true)
    (lib.cmakeBool "ENABLE_TESTS" false)
    (lib.cmakeBool "ENABLE_HTTP_SERVER" false)
    # Would shell out to git against a .git that fetchFromGitHub strips.
    (lib.cmakeBool "ENABLE_GIT_VERSIONING" false)
    # Otherwise third_party/SDL2 is built static against whatever headers happen
    # to be visible at configure time, silently dropping backends.
    (lib.cmakeBool "USE_SYSTEM_SDL2" true)
  ];

  # Upstream ships no install() rules; the AppImage script scrapes the build dir.
  installPhase = ''
    runHook preInstall

    install -Dm755 Alber -t $out/bin
    install -Dm644 $src/.github/Alber.desktop -t $out/share/applications
    install -Dm644 $src/docs/img/Alber.png $out/share/icons/hicolor/512x512/apps/Alber.png

    runHook postInstall
  '';

  # miniaudio is the audio device and reaches ALSA, PulseAudio and PipeWire
  # through dlopen by soname, so they resolve against this and nothing else.
  qtWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${
      lib.makeLibraryPath [
        alsa-lib
        libpulseaudio
        pipewire
        vulkan-loader
      ]
    }"
  ];

  meta = {
    description = "HLE Nintendo 3DS emulator";
    homepage = "https://github.com/wheremyfoodat/Panda3DS";
    license = lib.licenses.gpl3Only;
    mainProgram = "Alber";
    platforms = [ "x86_64-linux" ];
  };
})
