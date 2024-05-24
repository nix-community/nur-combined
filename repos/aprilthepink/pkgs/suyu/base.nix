
{ pname, version, src, branchName
, stdenv, lib, wrapQtAppsHook
, cmake, pkg-config
, vulkan-loader, vulkan-headers
, qtbase, qtwebengine, qttools
, nlohmann_json
, zlib, zstd, lz4
, glslang
, boost
, catch2_3
, SDL2
, libusb1
, discord-rpc
, cpp-jwt
, cubeb
, enet
, autoconf
, yasm
, libva
, nv-codec-headers-12
, fmt
, libopus
, qtmultimedia
, qtwayland
, fetchurl
, unzip
, gitUpdater
}:
let
  nx_tzdb = import ./nz_tzdb.nix {inherit stdenv fetchurl unzip gitUpdater;};
in
stdenv.mkDerivation rec {
  inherit pname version src;

  nativeBuildInputs = [
    cmake
    glslang
    pkg-config
    qttools
    wrapQtAppsHook
  ];
  buildInputs = [
    # vulkan-headers must come first, so the older propagated versions
    # don't get picked up by accident
    vulkan-headers

    boost
    catch2_3
    cpp-jwt
    cubeb
    discord-rpc
    # intentionally omitted: dynarmic - prefer vendored version for compatibility
    enet

    # vendored ffmpeg deps
    autoconf
    yasm
    libva  # for accelerated video decode on non-nvidia
    nv-codec-headers-12  # for accelerated video decode on nvidia
    # end vendored ffmpeg deps

    fmt
    # intentionally omitted: gamemode - loaded dynamically at runtime
    # intentionally omitted: httplib - upstream requires an older version than what we have
    libopus
    libusb1
    # intentionally omitted: LLVM - heavy, only used for stack traces in the debugger
    lz4
    nlohmann_json
    qtbase
    qtmultimedia
    qtwayland
    qtwebengine
    # intentionally omitted: renderdoc - heavy, developer only
    SDL2
    # not packaged in nixpkgs: simpleini
    # intentionally omitted: stb - header only libraries, vendor uses git snapshot
    # not packaged in nixpkgs: vulkan-memory-allocator
    # intentionally omitted: xbyak - prefer vendored version for compatibility
    zlib
    zstd
  ];

  cmakeFlags = [
    # actually has a noticeable performance impact
    "-DYUZU_ENABLE_LTO=ON"

    # build with qt6
    "-DENABLE_QT6=ON"
    "-DENABLE_QT_TRANSLATION=ON"

    # use system libraries
    # NB: "external" here means "from the externals/ directory in the source",
    # so "off" means "use system"
    "-DYUZU_USE_EXTERNAL_SDL2=OFF"
    "-DYUZU_USE_EXTERNAL_VULKAN_HEADERS=OFF"

    # don't use system ffmpeg, yuzu uses internal APIs
    "-DYUZU_USE_BUNDLED_FFMPEG=ON"

    # don't check for missing submodules
    "-DYUZU_CHECK_SUBMODULES=OFF"

    # enable some optional features
    "-DYUZU_USE_QT_WEB_ENGINE=ON"
    "-DYUZU_USE_QT_MULTIMEDIA=ON"
    "-DUSE_DISCORD_PRESENCE=ON"

    # We dont want to bother upstream with potentially outdated compat reports
    "-DYUZU_ENABLE_COMPATIBILITY_REPORTING=OFF"
    "-DENABLE_COMPATIBILITY_LIST_DOWNLOAD=OFF" # We provide this deterministically
  ];

  # This changes `ir/opt` to `ir/var/empty` in `externals/dynarmic/src/dynarmic/CMakeLists.txt`
  # making the build fail, as that path does not exist
  dontFixCmake = true;

  # Does some handrolled SIMD
  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isx86_64 "-msse4.1";

  # Fixes vulkan detection.
  # FIXME: patchelf --add-rpath corrupts the binary for some reason, investigate
  qtWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${vulkan-loader}/lib"
  ];

  preConfigure = ''
    # Trick the configure system. This prevents a check for submodule directories.
    rm -f .gitmodules

    # see https://github.com/NixOS/nixpkgs/issues/114044, setting this through cmakeFlags does not work.
    cmakeFlagsArray+=(
      "-DTITLE_BAR_FORMAT_IDLE=yuzu ${branchName} ${version}"
      "-DTITLE_BAR_FORMAT_RUNNING=yuzu ${branchName} ${version} | {3}"
    )

    # provide pre-downloaded tz data
    mkdir -p build/externals/nx_tzdb
    ln -s ${nx_tzdb} build/externals/nx_tzdb/nx_tzdb
  '';

  # Fix vulkan detection
  postFixup = ''
    wrapProgram $out/bin/suyu --prefix LD_LIBRARY_PATH : ${vulkan-loader}/lib
    wrapProgram $out/bin/suyu-cmd --prefix LD_LIBRARY_PATH : ${vulkan-loader}/lib
  '';

  postInstall = ''
    install -Dm444 $src/dist/72-suyu-input.rules $out/lib/udev/rules.d/72-suyuu-input.rules
  '';

  meta = with lib; {
    homepage = "https://git.suyu.dev";
    description = "The ${branchName} branch of an experimental Nintendo Switch emulator written in C++";
    longDescription = ''
      An experimental Nintendo Switch emulator written in C++.
      Using the mainline branch is recommanded for general usage.
      Using the early-access branch is recommanded if you would like to try out experimental features, with a cost of stability.
    '';
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ aprl ];
    platforms = platforms.linux;
    broken = stdenv.isAarch64; # Currently aarch64 is not supported.
  };
}
