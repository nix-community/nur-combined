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
  writeScript,
  callPackage,
  wrapGAppsHook3,
}:

let
  nx_tzdb = callPackage ./nx_tzdb.nix { };

  # eden broken by latest httplib version bump
  # upstream likely not interested in fixes, actively looking to remove the dependency (https://git.eden-emu.dev/eden-emu/eden/issues/4194)
  # pin httplib for now, hopefully can entirely drop in next eden release
  httplib' = httplib.overrideAttrs (finalAttrs: {
    version = "0.30.2";

    src = fetchFromGitHub {
      owner = "yhirose";
      repo = "cpp-httplib";
      rev = "v${finalAttrs.version}";
      hash = "sha256-psVyn14QHMXG/x9SOOiR7ZBt8dHqa2A/w92WQQDukKM=";
    };
  });

  zbic = fetchFromGitHub {
    owner = "kinnay";
    repo = "zbic";
    rev = "11b08f2712264bbed731545085cbd9702096ceb7";
    hash = "sha256-pHvxa1gkUvQo6mUgmLWtj1kcu01BLdGmttZyb8ZAj/o=";
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "lichii";
  version = "build-93";

  src = fetchFromGitHub {
    owner = "zortos293";
    repo = "Lichii";
    tag = finalAttrs.version;
    hash = "sha256-2UnbfvLqlgHdQh3m8YKXpOnXxHomshXiLUeb34REMl0=";
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
    httplib'
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
      --replace-fail 'AddJsonPackage(NAME zbic DOWNLOAD_ONLY)' ""

    substituteInPlace externals/CMakeLists.txt \
      --replace-fail ''\'''${zbic_SOURCE_DIR}' ${zbic}
  '';

  doCheck = false;

  checkInputs = [
    catch2_3
    oaknut
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TESTING" finalAttrs.finalPackage.doCheck)
    (lib.cmakeBool "YUZU_TESTS" false) # some timer tests are flaky

    # use system libraries
    (lib.cmakeBool "CPMUTIL_FORCE_SYSTEM" true)
    (lib.cmakeFeature "YUZU_TZDB_PATH" "${nx_tzdb}")

    # enable some optional features
    (lib.cmakeBool "YUZU_USE_QT_WEB_ENGINE" true)
    (lib.cmakeBool "YUZU_USE_QT_MULTIMEDIA" true)
    (lib.cmakeBool "ENABLE_QT_TRANSLATION" true)
    (lib.cmakeBool "ENABLE_LTO" true)

    # don't treat warnings as errors
    (lib.cmakeBool "ENABLE_WERROR" false)

    # disable features not packaged in Nix
    (lib.cmakeBool "ENABLE_RESHADE" false)

    # We dont want to bother upstream with potentially outdated compat reports
    (lib.cmakeBool "YUZU_ENABLE_COMPATIBILITY_REPORTING" false)

    (lib.cmakeFeature "TITLE_BAR_FORMAT_IDLE" "${finalAttrs.pname} | ${finalAttrs.version} (nixpkgs) {}")
    (lib.cmakeFeature "TITLE_BAR_FORMAT_RUNNING" "${finalAttrs.pname} | ${finalAttrs.version} (nixpkgs) | {}")
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

  passthru = {
    inherit nx_tzdb;

    updateScript = writeScript "update-lichii" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p nix-update

      set -eu -o pipefail

      nix-update lichii
      nix-update lichii.nx_tzdb
    '';
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
