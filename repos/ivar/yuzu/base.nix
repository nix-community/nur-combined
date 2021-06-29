{ pname, version, src, branchName
, stdenv, lib, fetchFromGitHub, wrapQtAppsHook
, cmake, pkg-config
, libpulseaudio, libjack2, alsaLib, sndio
, vulkan-loader, vulkan-headers
, qtbase, qtwebengine, qttools
, nlohmann_json, rapidjson
, zlib, zstd, libzip, lz4
, glslang
, boost173
, catch2
, fmt
, SDL2
, udev
, libusb1
, ffmpeg
}:

stdenv.mkDerivation rec {
  inherit pname version src;

  nativeBuildInputs = [ cmake pkg-config wrapQtAppsHook ];
  buildInputs = [
    libpulseaudio libjack2 alsaLib sndio
    vulkan-loader vulkan-headers
    qtbase qtwebengine qttools
    nlohmann_json rapidjson
    zlib zstd libzip lz4
    glslang
    boost173
    catch2
    fmt
    SDL2
    udev
    libusb1
    ffmpeg
  ];

  # TODO: Remove this when https://github.com/NixOS/nixpkgs/pull/124870 hits the channels
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "1.5         zstd/1.5.0" "1.4.9         zstd/1.4.9" \
      --replace "8.0         fmt/8.0.0" "7.1.3         fmt/7.1.3"

  '';

  cmakeFlags = [
    "-DENABLE_QT_TRANSLATION=ON"
    "-DYUZU_USE_QT_WEB_ENGINE=ON"
    "-DUSE_DISCORD_PRESENCE=ON"
    # Shows errors about not being able to find .git at runtime if you do not set these
    "-DGIT_BRANCH=\"\""
    "-DGIT_DESC=\"\""
  ];

  # This changes `ir/opt` to `ir/var/empty` in `externals/dynarmic/src/dynarmic/CMakeLists.txt`
  # making the build fail, as that path does not exist
  dontFixCmake = true;

  preConfigure = ''
    rm -f .gitmodules # Trick the configure system. This prevents a check for submodule directories.
    cmakeFlagsArray+=( # https://github.com/NixOS/nixpkgs/issues/114044
      "-DTITLE_BAR_FORMAT_IDLE=yuzu ${branchName} ${version}"
      "-DTITLE_BAR_FORMAT_RUNNING=yuzu ${branchName} ${version} | {3}"
    )
  '';

  # Fix vulkan detection
  postFixup = ''
    wrapProgram $out/bin/yuzu --prefix LD_LIBRARY_PATH : ${vulkan-loader}/lib
    wrapProgram $out/bin/yuzu-cmd --prefix LD_LIBRARY_PATH : ${vulkan-loader}/lib
  '';

  meta = with lib; {
    homepage = "https://yuzu-emu.org";
    description = "The ${branchName} branch of an experimental Nintendo Switch emulator written in C++";
    longDescription = ''
      An experimental Nintendo Switch emulator written in C++.
      Using the mainline branch is recommanded for general usage.
      Using the early-access branch is recommanded if you would like to try out experimental features, with a cost of stability.
    '';
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ ivar joshuafern ];
    platforms = platforms.linux;
  };
}
