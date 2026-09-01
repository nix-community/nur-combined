{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchzip,
  autoPatchelfHook,
  buildNpmPackage,
  cmake,
  pkg-config,
  python3,
  wayland-scanner,
  avahi,
  boost,
  curl,
  libappindicator,
  libcap,
  libdrm,
  libevdev,
  libgbm,
  libglvnd,
  libmsquic,
  libnotify,
  libopus,
  libpulseaudio,
  libva,
  libx11,
  libxcb,
  libxfixes,
  libxrandr,
  libxtst,
  miniupnpc,
  nlohmann_json,
  numactl,
  openssl,
  udevCheckHook,
  wayland,
}:
let
  ffmpegPrebuilt = fetchzip {
    url = "https://github.com/LizardByte/build-deps/releases/download/v2026.516.30821/Linux-x86_64-ffmpeg.tar.gz";
    hash = "sha256-VT+4qP2FaizCoIBBbBkzbYw4YOvGhuBUoZxWL0IYVZo=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "helios";
  version = "0.6.1";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "moonlight-os";
    repo = "helios";
    tag = "v${finalAttrs.version}";
    hash = "sha256-J6zYP91guzCvQ5iDPWGbuhHOdIuBpTeOgXRWvpC955I=";
    fetchSubmodules = true;
  };

  ui = buildNpmPackage {
    inherit (finalAttrs) src version;
    pname = "helios-ui";
    npmDepsHash = "sha256-RIorrxMPheZhYAemw9tZuyWieq1klLQ2gsh2ztiic6c=";
    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -a . "$out"/
      runHook postInstall
    '';
  };

  postPatch = ''
        # v0.5.1 prepended the FFmpeg bundle after the pinned NVENC headers, which
        # let a newer bundle override the API Helios was written against. The
        # source fix is included after v0.5.1, so keep this backport version-bound.
        if [[ "${finalAttrs.version}" == "0.5.1" ]]; then
          substituteInPlace cmake/compile_definitions/common.cmake \
            --replace-fail 'include_directories(BEFORE SYSTEM "''${CMAKE_SOURCE_DIR}/third-party/nv-codec-headers/include")' ""
          substituteInPlace cmake/compile_definitions/common.cmake \
            --replace-fail '        ''${Boost_INCLUDE_DIRS}  # has to be the last, or we get runtime error on macOS ffmpeg encoder
    )' '        ''${Boost_INCLUDE_DIRS}  # has to be the last, or we get runtime error on macOS ffmpeg encoder
    )
    include_directories(BEFORE SYSTEM "''${CMAKE_SOURCE_DIR}/third-party/nv-codec-headers/include")'
        fi

        substituteInPlace cmake/targets/common.cmake \
          --replace-fail 'find_program(NPM npm REQUIRED)' ""

        # Keep CMake on its prepared-bundle branch so the static codec libraries
        # accompanying libavcodec remain in the link set. Passing this as the
        # FFMPEG_PREPARED_BINARIES cache variable selects the system-FFmpeg branch.
        substituteInPlace cmake/dependencies/common.cmake \
          --replace-fail '"''${CMAKE_SOURCE_DIR}/third-party/build-deps/dist/''${CMAKE_SYSTEM_NAME}-''${CMAKE_SYSTEM_PROCESSOR}"' \
          '"${ffmpegPrebuilt}"'

        sed -i -E 's/set\(BOOST_VERSION "[^"]*"\)/set(BOOST_VERSION "${boost.version}")/' \
          cmake/dependencies/Boost_Helios.cmake
        echo 'set(FETCH_CONTENT_BOOST_USED TRUE)' >> cmake/dependencies/Boost_Helios.cmake

        substituteInPlace cmake/packaging/linux.cmake \
          --replace-fail 'find_package(Systemd)' "" \
          --replace-fail 'find_package(Udev)' ""

        substituteInPlace packaging/linux/dev.mopigames.Helios.desktop \
          --replace-fail '/usr/bin/env systemctl start --u helios' 'helios'
  '';

  nativeBuildInputs = [
    autoPatchelfHook
    cmake
    pkg-config
    (python3.withPackages (ps: [
      ps.jinja2
      ps.setuptools
    ]))
    wayland-scanner
  ];

  buildInputs = [
    avahi
    boost
    curl
    libappindicator
    libcap
    libdrm
    libevdev
    libgbm
    libmsquic
    libnotify
    libopus
    libpulseaudio
    libva
    libx11
    libxcb
    libxfixes
    libxrandr
    libxtst
    miniupnpc
    nlohmann_json
    numactl
    openssl
    wayland
  ];

  runtimeDependencies = [
    avahi
    libgbm
    libglvnd
    libmsquic
    libxcb
    libxrandr
  ];

  cmakeFlags = [
    "-Wno-dev"
    (lib.cmakeBool "BOOST_USE_STATIC" false)
    (lib.cmakeBool "BUILD_DOCS" false)
    (lib.cmakeBool "BUILD_TESTS" false)
    (lib.cmakeBool "CUDA_FAIL_ON_MISSING" false)
    (lib.cmakeBool "ENABLE_MLOS_QUIC" true)
    (lib.cmakeBool "SUNSHINE_ENABLE_CUDA" false)
    (lib.cmakeBool "UDEV_FOUND" true)
    (lib.cmakeBool "SYSTEMD_FOUND" true)
    (lib.cmakeFeature "MSQUIC_LIBRARY" "${lib.getLib libmsquic}/lib/libmsquic.so")
    (lib.cmakeFeature "SUNSHINE_PUBLISHER_NAME" "NUR")
    (lib.cmakeFeature "SUNSHINE_PUBLISHER_WEBSITE" "https://github.com/moonlight-os/helios")
    (lib.cmakeFeature "SUNSHINE_PUBLISHER_ISSUE_URL" "https://github.com/moonlight-os/helios/issues")
    (lib.cmakeFeature "UDEV_RULES_INSTALL_DIR" "lib/udev/rules.d")
    (lib.cmakeFeature "SYSTEMD_USER_UNIT_INSTALL_DIR" "lib/systemd/user")
    (lib.cmakeFeature "SYSTEMD_SYSTEM_UNIT_INSTALL_DIR" "lib/systemd/system")
    (lib.cmakeFeature "SYSTEMD_MODULES_LOAD_DIR" "lib/modules-load.d")
    (lib.cmakeFeature "SUNSHINE_EXECUTABLE_PATH" "${placeholder "out"}/bin/helios")
  ];

  env = {
    BUILD_VERSION = finalAttrs.version;
    BRANCH = "main";
    COMMIT = finalAttrs.src.rev;
  };

  preBuild = ''
    cp -r ${finalAttrs.ui}/build ../
  '';

  buildFlags = [ "helios" ];

  installPhase = ''
    runHook preInstall
    cmake --install .
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ udevCheckHook ];

  meta = {
    description = "Game stream host for Selene and Moonlight OS";
    homepage = "https://github.com/moonlight-os/helios";
    license = lib.licenses.gpl3Only;
    mainProgram = "helios";
    platforms = [ "x86_64-linux" ];
  };
})
