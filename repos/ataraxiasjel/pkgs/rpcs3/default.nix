{ lib, stdenv, fetchFromGitHub, wrapQtAppsHook, cmake, pkg-config, git
, qtbase, qtmultimedia, qtwayland, openal, glew, vulkan-headers, vulkan-loader, libpng, libSM
, ffmpeg, libevdev, libusb1, zlib, curl, wolfssl, python3, pugixml, faudio, flatbuffers
, sdl2Support ? true, SDL2
, cubebSupport ? true, cubeb
, waylandSupport ? true, wayland
}:

let
  # Keep these separate so the update script can regex them
  rpcs3GitVersion = "15927-61e130e68";
  rpcs3Version = "0.0.30-15927-61e130e68";
  rpcs3Revision = "61e130e68c16bd00e4d9be064217198dc028928e";
  rpcs3Sha256 = "02kiczjg8q51sr98skyj0i3kmizp4x90f752ni28lq3rss7car1w";

  ittapi = fetchFromGitHub {
    owner = "intel";
    repo = "ittapi";
    rev = "v3.18.12";
    sha256 = "0c3g30rj1y8fbd2q4kwlpg1jdy02z4w5ryhj3yr9051pdnf4kndz";
  };
in
stdenv.mkDerivation {
  pname = "rpcs3";
  version = rpcs3Version;

  src = fetchFromGitHub {
    owner = "RPCS3";
    repo = "rpcs3";
    rev = rpcs3Revision;
    fetchSubmodules = true;
    sha256 = rpcs3Sha256;
  };

  patches = [ ./0001-llvm-ExecutionEngine-IntelJITEvents-only-use-ITTAPI_.patch ];

  passthru.updateScript = ./update.sh;

  preConfigure = ''
    cat > ./rpcs3/git-version.h <<EOF
    #define RPCS3_GIT_VERSION "${rpcs3GitVersion}"
    #define RPCS3_GIT_FULL_BRANCH "RPCS3/rpcs3/master"
    #define RPCS3_GIT_BRANCH "HEAD"
    #define RPCS3_GIT_VERSION_NO_UPDATE 1
    EOF
  '';

  cmakeFlags = [
    "-DUSE_SYSTEM_ZLIB=ON"
    "-DUSE_SYSTEM_LIBUSB=ON"
    "-DUSE_SYSTEM_LIBPNG=ON"
    "-DUSE_SYSTEM_FFMPEG=ON"
    "-DUSE_SYSTEM_CURL=ON"
    "-DUSE_SYSTEM_WOLFSSL=ON"
    "-DUSE_SYSTEM_FAUDIO=ON"
    "-DUSE_SYSTEM_PUGIXML=ON"
    "-DUSE_SYSTEM_FLATBUFFERS=ON"
    "-DUSE_NATIVE_INSTRUCTIONS=OFF"
    "-DITTAPI_SOURCE_DIR=${ittapi}"
    "-DBUILD_LLVM=ON"
    "-DSTATIC_LINK_LLVM=ON"
  ];

  nativeBuildInputs = [ cmake pkg-config git wrapQtAppsHook ];

  buildInputs = [
    qtbase qtmultimedia qtwayland openal glew vulkan-headers vulkan-loader libpng ffmpeg
    libevdev zlib libusb1 curl wolfssl python3 pugixml faudio flatbuffers libSM
  ] ++ lib.optional sdl2Support SDL2
    ++ lib.optionals cubebSupport cubeb.passthru.backendLibs
    ++ lib.optional waylandSupport wayland;

  postInstall = ''
    # Taken from https://wiki.rpcs3.net/index.php?title=Help:Controller_Configuration
    install -D ${./99-ds3-controllers.rules} $out/etc/udev/rules.d/99-ds3-controllers.rules
    install -D ${./99-ds4-controllers.rules} $out/etc/udev/rules.d/99-ds4-controllers.rules
    install -D ${./99-dualsense-controllers.rules} $out/etc/udev/rules.d/99-dualsense-controllers.rules
  '';

  meta = with lib; {
    description = "PS3 emulator/debugger";
    homepage = "https://rpcs3.net/";
    maintainers = with maintainers; [ ataraxiasjel ];
    license = licenses.gpl2Only;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
