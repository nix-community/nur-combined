{
  lib,
  stdenv,
  fetchFromGitea,
  cacert,
  cmake,
  glslang,
  pkg-config,
  python3,
  qt6Packages,
  vulkan-headers,
  boost,
  cpp-jwt,
  cubeb,
  discord-rpc,
  enet,
  ffmpeg-headless,
  fmt,
  gamemode,
  httplib,
  libopus,
  libusb1,
  openssl,
  lz4,
  mbedtls,
  nlohmann_json,
  SDL2,
  simpleini,
  spirv-headers,
  spirv-tools,
  unordered_dense,
  vulkan-memory-allocator,
  vulkan-utility-libraries,
  zlib,
  zstd,
  vulkan-loader,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "eden";
  version = "0.0.4-rc2";

  src = fetchFromGitea {
    domain = "git.eden-emu.dev";
    owner = "eden-emu";
    repo = "eden";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SMBzvUpBHQeBtGxEi9VfhWn7WlxJtpxbfVFQtXnTWZ8=";
  };

  deps = stdenv.mkDerivation {
    name = "eden-deps-${finalAttrs.version}.tar.gz";

    inherit (finalAttrs) src;

    nativeBuildInputs = finalAttrs.nativeBuildInputs ++ [ cacert ];

    inherit (finalAttrs) buildInputs __structuredAttrs cmakeFlags;

    dontBuild = true;

    installPhase = ''
      cd "$cmakeDir"
      # Build a reproducible tar, per instructions at https://reproducible-builds.org/docs/archives/
      tar --owner=0 --group=0 --numeric-owner --format=gnu \
        --sort=name --mtime="@$SOURCE_DATE_EPOCH" \
        -czf $out .cache/cpm
    '';

    outputHash = "sha256-b3I7dspF85NyChG3LqLwvtFjx88ZrBMJQIPkbUOVJAA=";
    outputHashAlgo = "sha256";
  };

  nativeBuildInputs = [
    cmake
    glslang
    pkg-config
    python3
  ]
  ++ (with qt6Packages; [
    qttools
    wrapQtAppsHook
  ]);

  buildInputs = [
    # vulkan-headers must come first, so the older propagated versions
    # don't get picked up by accident
    vulkan-headers

    boost
    # intentionally omitted: catch2_3 - only used for tests
    cpp-jwt
    cubeb
    discord-rpc
    # intentionally omitted: dynarmic - prefer vendored version for compatibility
    enet
    ffmpeg-headless
    fmt
    gamemode
    httplib
    libopus
    libusb1
    openssl
    # intentionally omitted: LLVM - heavy, only used for stack traces in the debugger
    lz4
    mbedtls
    nlohmann_json
    # intentionally omitted: renderdoc - heavy, developer only
    SDL2
    # intentionally omitted: stb - header only libraries, vendor uses git snapshot
    simpleini
    spirv-headers
    spirv-tools
    unordered_dense
    vulkan-memory-allocator
    vulkan-utility-libraries
    # intentionally omitted: xbyak - prefer vendored version for compatibility
    zlib
    zstd
  ]
  ++ (with qt6Packages; [
    qtbase
    qtmultimedia
    qtwayland
    qtwebengine
  ]);

  postUnpack = ''
    mkdir -p "$sourceRoot"
    tar -xf "$deps" -C "$sourceRoot"
  '';

  __structuredAttrs = true;
  cmakeFlags = [
    # actually has a noticeable performance impact
    (lib.cmakeBool "YUZU_ENABLE_LTO" true)
    (lib.cmakeBool "DYNARMIC_ENABLE_LTO" true)

    # use system libraries
    # NB: "external" here means "from the externals/ directory in the source",
    # so "false" means "use system"
    (lib.cmakeBool "YUZU_USE_EXTERNAL_SDL2" false)

    # enable some optional features
    (lib.cmakeBool "ENABLE_QT_TRANSLATION" true)
    (lib.cmakeBool "USE_DISCORD_PRESENCE" true)
    (lib.cmakeBool "YUZU_USE_QT_MULTIMEDIA" true)
    (lib.cmakeBool "YUZU_USE_QT_WEB_ENGINE" true)

    (lib.cmakeFeature "TITLE_BAR_FORMAT_IDLE" "eden | ${finalAttrs.version} (nixpkgs) {}")
    (lib.cmakeFeature "TITLE_BAR_FORMAT_RUNNING" "eden | ${finalAttrs.version} (nixpkgs) | {}")
  ];

  env = {
    # Does some handrolled SIMD
    NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isx86_64 "-msse4.2";
  };

  qtWrapperArgs = [
    # Fixes vulkan detection.
    # FIXME: patchelf --add-rpath corrupts the binary for some reason, investigate
    "--prefix LD_LIBRARY_PATH : ${vulkan-loader}/lib"
  ];

  postInstall = ''
    install -Dm444 "$src/dist/72-yuzu-input.rules" "$out/lib/udev/rules.d/72-yuzu-input.rules"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Nintendo Switch video game console emulator";
    homepage = "https://git.eden-emu.dev/eden-emu/eden";
    changelog = "https://git.eden-emu.dev/eden-emu/eden/releases/tag/${finalAttrs.src.tag}";
    mainProgram = "eden";
    platforms = lib.platforms.linux;
    license = with lib.licenses; [
      gpl3Plus

      # Icons
      asl20
      mit
      cc0
    ];

    maintainers = with lib.maintainers; [ kira-bruneau ];
  };
})
