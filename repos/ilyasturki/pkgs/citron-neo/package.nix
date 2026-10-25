{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  cmake,
  ninja,
  pkg-config,
  glslang,
  unzip,
  qt6Packages,
  wrapGAppsHook3,
  alsa-lib,
  boost,
  dbus,
  ffmpeg,
  fmt,
  gsettings-desktop-schemas,
  gtk3,
  libGL,
  libdecor,
  libdrm,
  libopus,
  libpulseaudio,
  libusb1,
  libva,
  libx11,
  libxcb,
  libxcursor,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  lz4,
  nlohmann_json,
  nv-codec-headers-12,
  openssl,
  pipewire,
  udev,
  vulkan-loader,
  wayland,
  wayland-protocols,
  wayland-scanner,
  zlib,
  zstd,
}:

let
  # externals/nx_tzdb builds this from the tzdb_to_nx submodule when it finds
  # git, make and date -- and that build fetches IANA tzdata over the network,
  # which the sandbox forbids. Unpacking the release archive upstream would
  # otherwise download, into the directory its EXISTS guard checks, takes both
  # branches out of play. The version is pinned by nx_tzdb's own CMakeLists.
  nxTzdbVersion = "221202";
  nxTzdb = fetchurl {
    url = "https://github.com/lat9nq/tzdb_to_nx/releases/download/${nxTzdbVersion}/${nxTzdbVersion}.zip";
    hash = "sha256-mRzW+iIwrU1zsxHmf+0RArU8BShAoEMvCz+McXFFK3c=";
  };
in
stdenv.mkDerivation {
  pname = "citron-neo";
  version = "0-unstable-2026-10-24";

  src = fetchFromGitHub {
    owner = "citron-neo";
    repo = "emulator";
    rev = "56dad8119520160b744b959ba07f1e19538e97c1";
    hash = "sha256-524LtsduT65hfPJYIVRyXtdui99pKduU/2Fhm99Y+5k=";
    # Every external lives in externals/ as a submodule and CITRON_USE_CPM is
    # off by default, so this is the whole dependency tree: nothing is fetched
    # at configure time.
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    glslang
    unzip
    wayland-scanner
    qt6Packages.wrapQtAppsHook
    qt6Packages.qttools
    wrapGAppsHook3
  ];

  buildInputs = [
    qt6Packages.qtbase
    qt6Packages.qtmultimedia
    qt6Packages.qtwayland

    # Citron's Qt file dialog uses the GTK backend, which aborts without
    # org.gtk.Settings.FileChooser.
    gtk3
    gsettings-desktop-schemas

    vulkan-loader

    boost
    ffmpeg
    fmt
    libopus
    libusb1
    libva
    lz4
    nlohmann_json
    nv-codec-headers-12
    openssl
    zlib
    zstd

    alsa-lib
    libpulseaudio
    pipewire

    dbus
    libGL
    libdrm
    libdecor
    libxkbcommon
    wayland
    wayland-protocols
    udev
    libx11
    libxcb
    libxcursor
    libxext
    libxfixes
    libxi
    libxrandr
  ];

  patches = [
    # Upstream d169db4c7, lost when bfd8551ff reverted to the dynarmic submodule:
    # without it the x64 backend does not compile.
    ./dynarmic-x64-backend.patch
    # A local struct reuses a member's name, which only GCC flags under the
    # tree's -Werror=shadow.
    ./texture-cache-shadow.patch
  ];

  preConfigure = ''
    # nx_tzdb's EXISTS guard is version-blind, so a bumped NX_TZDB_VERSION would
    # silently keep the archive unpacked here instead of the one it asked for.
    grep -q 'set(NX_TZDB_VERSION "${nxTzdbVersion}")' externals/nx_tzdb/CMakeLists.txt || {
      echo "nx_tzdb no longer pins NX_TZDB_VERSION ${nxTzdbVersion}; update nxTzdbVersion and its hash" >&2
      exit 1
    }

    # preConfigure runs before the cmake hook assigns cmakeBuildDir's default.
    mkdir -p "''${cmakeBuildDir:-build}/externals/nx_tzdb/nx_tzdb"
    unzip -q ${nxTzdb} -d "''${cmakeBuildDir:-build}/externals/nx_tzdb/nx_tzdb"
  '';

  cmakeFlags = [
    # The check tests every .gitmodules path for a .git entry, which
    # fetchFromGitHub strips, so it fails on the first submodule regardless of
    # the sources actually being there.
    (lib.cmakeBool "CITRON_CHECK_SUBMODULES" false)
    (lib.cmakeBool "CITRON_USE_CPM" false)
    (lib.cmakeBool "CITRON_USE_BUNDLED_VCPKG" false)
    (lib.cmakeBool "CITRON_USE_BUNDLED_FFMPEG" false)
    (lib.cmakeBool "CITRON_TESTS" false)
    (lib.cmakeBool "CITRON_USE_PRECOMPILED_HEADERS" false)
    (lib.cmakeBool "CITRON_ENABLE_LTO" false)
    # Paired with the preConfigure unpack above: ON keeps CMake out of the
    # tzdb_to_nx branch, and the directory already being there keeps it out of
    # the download.
    (lib.cmakeBool "CITRON_DOWNLOAD_TIME_ZONE_DATA" true)
    (lib.cmakeBool "ENABLE_QT" true)
    (lib.cmakeBool "ENABLE_QT_TRANSLATION" true)
    (lib.cmakeBool "ENABLE_SDL2" true)
    (lib.cmakeBool "ENABLE_CUBEB" true)
    (lib.cmakeBool "ENABLE_WEB_SERVICE" false)
    (lib.cmakeBool "CITRON_USE_QT_MULTIMEDIA" true)
    (lib.cmakeBool "CITRON_USE_QT_WEB_ENGINE" false)
  ];

  # The vendored cubeb and SDL2 reach the audio backends, and SDL2 reaches libudev
  # for gamepad hotplug, through dlopen by soname, so nothing links them.
  qtWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${
      lib.makeLibraryPath [
        alsa-lib
        libpulseaudio
        pipewire
        udev
        vulkan-loader
      ]
    }"
  ];

  dontWrapGApps = true;
  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postInstall = ''
    install -Dm644 $src/dist/72-citron-input.rules -t $out/lib/udev/rules.d
    install -Dm644 $src/dist/org.citron_emu.citron.desktop -t $out/share/applications
    install -Dm644 $src/dist/org.citron_emu.citron.metainfo.xml -t $out/share/metainfo
    install -Dm644 $src/dist/org.citron_emu.citron.xml -t $out/share/mime/packages
    install -Dm644 $src/dist/citron.svg $out/share/icons/hicolor/scalable/apps/org.citron_emu.citron.svg
  '';

  meta = {
    description = "Citron NEO: Nintendo Switch emulator, continuation of the Citron fork of yuzu";
    homepage = "https://citron-neo.org/";
    changelog = "https://github.com/citron-neo/emulator/commits/main";
    license = lib.licenses.gpl3Plus;
    mainProgram = "citron";
    platforms = [ "x86_64-linux" ];
  };
}
