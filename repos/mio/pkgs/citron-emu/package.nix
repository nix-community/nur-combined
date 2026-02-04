{
  lib,
  stdenv,
  SDL2,
  boost,
  catch2_3,
  cmake,
  ninja,
  fetchFromGitea,
  cpp-jwt,
  cubeb,
  gamemode,
  discord-rpc,
  enet,
  fetchzip,
  ffmpeg-headless,
  fmt,
  glslang,
  openal,
  libopus,
  libusb1,
  libva,
  lz4,
  python3,
  wrapGAppsHook3,
  nlohmann_json,
  rapidjson,
  openssl,
  pkg-config,
  qt6,
  spirv-tools,
  spirv-headers,
  vulkan-utility-libraries,
  vulkan-headers,
  vulkan-loader,
  simpleini,
  zlib,
  vulkan-memory-allocator,
  zstd,
  callPackage,
  withDiscordPresence ? true,
  withOptimisation ? true,
}@args:
let
  nx_tzdbVersion = "221202";
  nx_tzdb = fetchzip {
    url = "https://github.com/lat9nq/tzdb_to_nx/releases/download/${nx_tzdbVersion}/${nx_tzdbVersion}.zip";
    hash = "sha256-YOIElcKTiclem05trZsA3YJReozu/ex7jJAKD6nAMwc=";
    stripRoot = false;
  };
  inherit (qt6)
    qtbase
    qtmultimedia
    qttools
    qtwayland
    qtwebengine
    wrapQtAppsHook
    ;
in
stdenv.mkDerivation (finalAttrs: {
  inherit nx_tzdb;
  pname = "citron-emu";
  version = "0.12.25";
  src = fetchFromGitea {
    fetchSubmodules = true;
    domain = "git.citron-emu.org";
    owner = "Citron";
    repo = "Emulator";
    tag = finalAttrs.version;
    hash = "sha256-Su+SvCb6KDF9/ilb6Y/RZTOq/ffaMTWiJZy8nmGZ3n4=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    glslang
    pkg-config
    python3
    qttools
    wrapGAppsHook3
    wrapQtAppsHook
  ];

  buildInputs = [
    vulkan-headers
    boost
    catch2_3
    cpp-jwt
    cubeb
    enet
    ffmpeg-headless
    fmt
    openal
    libopus
    libusb1
    libva
    lz4
    nlohmann_json
    rapidjson
    openssl
    qtbase
    qtmultimedia
    qtwayland
    qtwebengine
    gamemode
    SDL2
    simpleini
    spirv-tools
    spirv-headers
    vulkan-loader
    vulkan-memory-allocator
    vulkan-utility-libraries
    zlib
    zstd
  ]
  ++ lib.optionals withDiscordPresence [
    discord-rpc
  ];

  __structuredAttrs = true;
  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5")
    (lib.cmakeBool "CITRON_ENABLE_LTO" true)
    (lib.cmakeBool "CITRON_TESTS" false)
    (lib.cmakeBool "ENABLE_QT" true)
    (lib.cmakeBool "USE_SYSTEM_QT" true)
    (lib.cmakeBool "ENABLE_QT_TRANSLATION" true)
    (lib.cmakeBool "CITRON_USE_EXTERNAL_SDL2" false)
    (lib.cmakeBool "CITRON_USE_EXTERNAL_VULKAN_HEADERS" false)
    (lib.cmakeBool "CITRON_USE_EXTERNAL_VULKAN_UTILITY_LIBRARIES" false)
    (lib.cmakeBool "CITRON_USE_EXTERNAL_VULKAN_SPIRV_TOOLS" false)
    (lib.cmakeBool "CITRON_DOWNLOAD_TIME_ZONE_DATA" false)
    (lib.cmakeBool "CITRON_CHECK_SUBMODULES" false)
    (lib.cmakeBool "CITRON_USE_QT_WEB_ENGINE" true)
    (lib.cmakeBool "CITRON_USE_QT_MULTIMEDIA" true)
    (lib.cmakeBool "USE_DISCORD_PRESENCE" withDiscordPresence)
    (lib.cmakeBool "CITRON_ENABLE_COMPATIBILITY_REPORTING" false)
    (lib.cmakeBool "CITRON_USE_AUTO_UPDATER" false)
    (lib.cmakeFeature "TITLE_BAR_FORMAT_IDLE" "${finalAttrs.pname} | ${finalAttrs.version} (nixpkgs) {}")
    (lib.cmakeFeature "TITLE_BAR_FORMAT_RUNNING" "${finalAttrs.pname} | ${finalAttrs.version} (nixpkgs) | {}")
  ]
  ++ lib.optionals withOptimisation [
    (lib.cmakeFeature "CMAKE_C_FLAGS" "-march=x86-64-v3")
    (lib.cmakeFeature "CMAKE_CXX_FLAGS" "-march=x86-64-v3")
  ];

  env = {
    NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isx86_64 "-msse4.1";
  };

  dontWrapGApps = true;
  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  preConfigure = ''
    # provide pre-downloaded tz data
    mkdir -p build/externals/nx_tzdb
    ln -s ${nx_tzdb} build/externals/nx_tzdb/nx_tzdb
  '';

  postPatch = ''
    # --- Qt 6.10: use GuiPrivate so qpa/qplatformnativeinterface.h is found ---

    # Add GuiPrivate to the Qt6 components
    substituteInPlace CMakeLists.txt \
      --replace "find_package(Qt6 REQUIRED COMPONENTS Widgets Multimedia Concurrent)" \
                "find_package(Qt6 REQUIRED COMPONENTS Widgets Multimedia Concurrent GuiPrivate)"

    # Link Qt6::GuiPrivate into the GUI target so its private headers are on the include path
    substituteInPlace src/citron/CMakeLists.txt \
      --replace "target_link_libraries(citron PRIVATE Boost::headers" \
                "target_link_libraries(citron PRIVATE Boost::headers Qt6::GuiPrivate"

    # --- Fix Qt 6 deprecation of QVariant::type() ---

    substituteInPlace src/citron/game_list.cpp \
      --replace "orig_icon_data.isValid() && orig_icon_data.type() == QVariant::Pixmap" \
                "orig_icon_data.isValid() && orig_icon_data.metaType().id() == QMetaType::QPixmap" \
      --replace "icon_data.isValid() && icon_data.type() == QVariant::Pixmap" \
                "icon_data.isValid() && icon_data.metaType().id() == QMetaType::QPixmap"
  '';

  postInstall = ''
    install -Dm444 $src/dist/72-citron-input.rules $out/lib/udev/rules.d/72-citron-input.rules
  '';

  meta = {
    homepage = "https://citron-emu.org";
    changelog = "https://git.citron-emu.org/";
    description = "Nintendo Switch emulator for PC";
    mainProgram = "citron";
    platforms = [ "x86_64-linux" ];
    license = with lib.licenses; [
      gpl3Plus
      # Icons
      asl20
      mit
      cc0
    ];
    maintainers = with lib.maintainers; [ samemrecebi ];
  };
})
