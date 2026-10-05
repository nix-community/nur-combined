{
  cmake,
  common-updater-scripts,
  cubeb,
  curl,
  enableDiscordRpc ? false,
  faudio,
  faudioSupport ? true,
  fetchFromGitHub,
  ffmpeg,
  git,
  glew,
  glslang,
  hidapi,
  lib,
  libevdev,
  libpng,
  libsm,
  libusb1,
  llvm,
  maintainer,
  miniupnpc,
  nix,
  openal,
  opencv,
  pkg-config,
  protobuf_33,
  pugixml,
  python3,
  qt6Packages,
  rtmidi,
  sdl3,
  stdenv,
  vulkan-headers,
  vulkan-loader,
  vulkan-memory-allocator,
  wayland,
  waylandSupport ? true,
  wrapGAppsHook3,
  writeShellApplication,
  zlib,
  zstd,
}:

let
  inherit (qt6Packages)
    qtbase
    qtmultimedia
    qtwayland
    wrapQtAppsHook
    ;
  submodules = lib.mapAttrs (_: pin: fetchFromGitHub pin) (
    builtins.fromJSON (builtins.readFile ./submodules.json)
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "rpcs3-git";
  version = "0.0.43-unstable-2026-10-05";

  src = fetchFromGitHub {
    hash = "sha256-/rIr9ZYaJ6ICluX+wCf3gXYLXxmTqD/2H2cYhcnTQy4=";
    owner = "RPCS3";
    # Independent archive fetches retain successful downloads when another fails.
    # Check gitlinks so an upstream update cannot silently reuse stale dependencies.
    postCheckout = lib.concatStrings (
      lib.mapAttrsToList (path: source: ''
        if [[ "$(git -C "$out" ls-tree HEAD ${lib.escapeShellArg path})" != ${lib.escapeShellArg "160000 commit ${source.rev}\t${path}"} ]]; then
          echo ${lib.escapeShellArg "Submodule ${path} does not match its cached pin; run the RPCS3 updater."} >&2
          exit 1
        fi
        cp -R ${source}/. "$out"/${lib.escapeShellArg path}/
      '') submodules
    );
    repo = "rpcs3";
    rev = "30ee6cc358180de6cb36cd961ac6f26f7bd3c10c";
  };

  nativeBuildInputs = [
    cmake
    git
    pkg-config
    wrapGAppsHook3
    wrapQtAppsHook
  ];

  buildInputs = [
    cubeb
    curl
    ffmpeg
    # RPCS3's X11 swap-interval path uses GLEW's GLXEW symbols, which
    # are not provided in the default EGL-enabled GLEW build.
    (glew.override { enableEGL = false; })
    glslang
    hidapi
    libevdev
    libpng
    libsm
    libusb1
    llvm
    miniupnpc
    openal
    opencv.cxxdev
    protobuf_33
    pugixml
    python3
    qtbase
    qtmultimedia
    rtmidi
    sdl3
    vulkan-headers
    vulkan-loader
    vulkan-memory-allocator
    zlib
    zstd
  ]
  ++ lib.optional faudioSupport faudio
  ++ lib.optionals waylandSupport [
    qtwayland
    wayland
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_LLVM" false)
    (lib.cmakeBool "BUILD_SHARED_LIBS" false)
    (lib.cmakeBool "USE_DISCORD_RPC" enableDiscordRpc)
    (lib.cmakeBool "USE_FAUDIO" faudioSupport)
    (lib.cmakeBool "USE_NATIVE_INSTRUCTIONS" false)
    (lib.cmakeBool "USE_SDL" true)
    (lib.cmakeBool "USE_SYSTEM_CUBEB" true)
    (lib.cmakeBool "USE_SYSTEM_CURL" true)
    (lib.cmakeBool "USE_SYSTEM_FAUDIO" true)
    (lib.cmakeBool "USE_SYSTEM_FFMPEG" true)
    (lib.cmakeBool "USE_SYSTEM_GLSLANG" true)
    (lib.cmakeBool "USE_SYSTEM_HIDAPI" true)
    (lib.cmakeBool "USE_SYSTEM_LIBPNG" true)
    (lib.cmakeBool "USE_SYSTEM_LIBUSB" true)
    (lib.cmakeBool "USE_SYSTEM_MINIUPNPC" true)
    (lib.cmakeBool "USE_SYSTEM_OPENCV" true)
    (lib.cmakeBool "USE_SYSTEM_OPENAL" true)
    (lib.cmakeBool "USE_SYSTEM_PROTOBUF" true)
    (lib.cmakeBool "USE_SYSTEM_PUGIXML" true)
    (lib.cmakeBool "USE_SYSTEM_RTMIDI" true)
    (lib.cmakeBool "USE_SYSTEM_SDL" true)
    (lib.cmakeBool "USE_SYSTEM_VULKAN_MEMORY_ALLOCATOR" true)
    (lib.cmakeBool "USE_SYSTEM_ZLIB" true)
    (lib.cmakeBool "USE_SYSTEM_ZSTD" true)
    (lib.cmakeBool "WITH_LLVM" true)
  ];

  dontWrapGApps = true;

  doInstallCheck = true;

  preConfigure = ''
    cat > ./rpcs3/git-version.h <<EOF
    #define RPCS3_GIT_VERSION "nixpkgs-${lib.sources.shortRev finalAttrs.src.rev}"
    #define RPCS3_GIT_FULL_BRANCH "RPCS3/rpcs3/master"
    #define RPCS3_GIT_BRANCH "HEAD"
    #define RPCS3_GIT_VERSION_NO_UPDATE 1
    EOF
  '';

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postInstall = ''
    # Taken from https://wiki.rpcs3.net/index.php?title=Help:Controller_Configuration
    install -D ${./99-ds3-controllers.rules} $out/etc/udev/rules.d/99-ds3-controllers.rules
    install -D ${./99-ds4-controllers.rules} $out/etc/udev/rules.d/99-ds4-controllers.rules
    install -D ${./99-dualsense-controllers.rules} $out/etc/udev/rules.d/99-dualsense-controllers.rules
  '';

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "update-rpcs3-git";
    runtimeInputs = [
      common-updater-scripts
      git
      nix
      python3
    ];
    text = ''exec python3 pkgs/rpcs3-git/update.py "$@"'';
  });

  meta = {
    description = "PS3 emulator/debugger";
    homepage = "https://rpcs3.net/";
    license = [
      lib.licenses.gpl2Only
      # RPCS3 vendors wolfSSL, whose GPL-3.0-or-later license is awkward
      # to combine with RPCS3's GPL-2.0-only license. Mark this unfree so
      # binary caches do not redistribute that combination by default.
      lib.licenses.gpl3Plus
      lib.licenses.unfree
    ];
    mainProgram = "rpcs3";
    maintainers = [ maintainer ];
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
})
