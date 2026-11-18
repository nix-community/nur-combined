{
  lib,
  stdenv,
  cmake,
  ninja,
  sdl3,
  boost,
  catch2_3,
  cpp-jwt,
  cubeb,
  enet,
  fetchFromGitHub,
  ffmpeg-headless,
  # FIXME: unpin when upstream supports fmt 12
  fmt_11,
  frozen-containers,
  gamemode,
  glslang,
  httplib,
  kdePackages,
  libopus,
  libusb1,
  lz4,
  nasm,
  nlohmann_json,
  oaknut,
  openssl,
  pipewire,
  pkg-config,
  python3,
  qt6,
  rt,
  simpleini,
  sirit,
  spirv-headers,
  stb,
  unordered_dense,
  vulkan-headers,
  vulkan-loader,
  vulkan-memory-allocator,
  vulkan-utility-libraries,
  xbyak,
  zlib,
  zstd,
  tzdb_to_nx,
  wrapGAppsHook3,
  gitUpdater,
}:

let
  xxhash = fetchFromGitHub {
    owner = "Cyan4973";
    repo = "xxHash";
    tag = "v0.8.3";
    hash = "sha256-h6kohM+NxvQ89R9NEXZcYBG2wPOuB4mcyPfofKrx9wQ=";
  };

  zbic = fetchFromGitHub {
    owner = "kinnay";
    repo = "zbic";
    rev = "11b08f2712264bbed731545085cbd9702096ceb7";
    hash = "sha256-pHvxa1gkUvQo6mUgmLWtj1kcu01BLdGmttZyb8ZAj/o=";
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "lichii";
  version = "341";

  src = fetchFromGitHub {
    owner = "zortos293";
    repo = "Lichii";
    tag = "build-${finalAttrs.version}";
    hash = "sha256-ZrphcBJ3W3gcsG1ZXkD6hSdiaophZ0g93mr8CKExZJg=";
  };

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    cmake
    ninja
    glslang
    pkg-config
    python3
    qt6.qttools
    qt6.wrapQtAppsHook
    wrapGAppsHook3
  ];

  buildInputs = [
    boost
    cpp-jwt
    cubeb
    enet
    ffmpeg-headless
    fmt_11
    frozen-containers
    gamemode
    httplib
    kdePackages.quazip
    libopus
    libusb1
    # intentionally omitted: LLVM - heavy, only used for stack traces in the debugger
    lz4
    nasm
    nlohmann_json
    openssl
    qt6.qtbase
    qt6.qtmultimedia
    qt6.qtwayland
    qt6.qtwebengine
    qt6.qtcharts
    # intentionally omitted: renderdoc - heavy, developer only
    rt
    sdl3
    stb
    simpleini
    spirv-headers
    vulkan-headers
    vulkan-memory-allocator
    vulkan-utility-libraries
    sirit
    unordered_dense
    zlib
    zstd
  ]
  ++ lib.optionals stdenv.hostPlatform.isx86_64 [
    xbyak
  ]
  ++ lib.optionals stdenv.hostPlatform.isAarch64 [
    oaknut
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'set(zstd_FORCE_BUNDLED ON)' ""

    substituteInPlace externals/CMakeLists.txt \
      --replace-fail 'AddJsonPackage(NAME xxhash DOWNLOAD_ONLY)' "" \
      --replace-fail ''\'''${xxhash_SOURCE_DIR}' ${xxhash} \
      --replace-fail 'AddJsonPackage(NAME zbic DOWNLOAD_ONLY)' "" \
      --replace-fail ''\'''${zbic_SOURCE_DIR}' ${zbic}
  '';

  doCheck = false;

  checkInputs = [
    catch2_3
    oaknut
  ];

  cmakeFlags = [
    # don't treat warnings as errors
    (lib.cmakeBool "ENABLE_WERROR" false)

    # use system libraries
    (lib.cmakeBool "CPMUTIL_FORCE_SYSTEM" true)
    (lib.cmakeFeature "LICHII_TZDB_PATH" "${tzdb_to_nx}")

    # disable features not packaged in Nix
    (lib.cmakeBool "ENABLE_RESHADE" false)

    # enable some optional features
    (lib.cmakeBool "LICHII_USE_QT_WEB_ENGINE" true)
    (lib.cmakeBool "LICHII_USE_QT_MULTIMEDIA" true)
    (lib.cmakeBool "ENABLE_QT_TRANSLATION" true)
    (lib.cmakeBool "ENABLE_LTO" true)

    # title formats
    (lib.cmakeFeature "TITLE_BAR_FORMAT_IDLE" "${finalAttrs.pname} | ${finalAttrs.version} (nixpkgs) {}")
    (lib.cmakeFeature "TITLE_BAR_FORMAT_RUNNING" "${finalAttrs.pname} | ${finalAttrs.version} (nixpkgs) | {}")

    # tests
    (lib.cmakeBool "BUILD_TESTING" finalAttrs.finalPackage.doCheck)
    (lib.cmakeBool "LICHII_TESTS" false) # some timer tests are flaky
  ];

  postInstall = ''
    install -Dm444 $src/dist/72-eden-input.rules $out/lib/udev/rules.d/72-eden-input.rules
  '';

  preFixup = ''
    qtWrapperArgs+=(--prefix LD_LIBRARY_PATH : ${
      lib.makeLibraryPath [
        vulkan-loader
        pipewire
      ]
    })
  '';

  passthru.updateScript = gitUpdater {
    rev-prefix = "build-";
  };

  meta = {
    description = "VERY experimental Nintendo Switch 2 emulator";
    homepage = "https://lichiiemulator.com";
    mainProgram = "lichii";
    maintainers = with lib.maintainers; [ kira-bruneau ];
    license = with lib.licenses; [
      # Primary
      gpl3Plus

      # Yuzu code & assets
      gpl2Plus
      # bsd0

      # Icons & Qt themes
      cc-by-40
      cc-by-sa-30
      cc0
      lgpl2Plus

      # Vendored/incorporated libs
      asl20
      bsd2
      bsd3
      lgpl3Plus
      lib.licenses.boost
      llvm-exception
      mit
      mpl20
      wtfpl
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
