{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  python3,
  yyjson_0_10,
  testers,
  nix-update-script,

  enableVulkan ?
    stdenv.hostPlatform.isLinux
    || stdenv.hostPlatform.isDarwin
    || stdenv.hostPlatform.isFreeBSD
    || stdenv.hostPlatform.isOpenBSD
    || stdenv.hostPlatform.isWindows
    || stdenv.hostPlatform.isAndroid
    || stdenv.hostPlatform.isSunOS,
  vulkan-loader,
  enableWayland ?
    stdenv.hostPlatform.isLinux || stdenv.hostPlatform.isFreeBSD || stdenv.hostPlatform.isOpenBSD,
  wayland,
  enableXcbRandr ?
    stdenv.hostPlatform.isLinux
    || stdenv.hostPlatform.isFreeBSD
    || stdenv.hostPlatform.isOpenBSD
    || stdenv.hostPlatform.isSunOS,
  enableXcb ?
    stdenv.hostPlatform.isLinux
    || stdenv.hostPlatform.isFreeBSD
    || stdenv.hostPlatform.isOpenBSD
    || stdenv.hostPlatform.isSunOS,
  enableXrandr ?
    stdenv.hostPlatform.isLinux
    || stdenv.hostPlatform.isFreeBSD
    || stdenv.hostPlatform.isOpenBSD
    || stdenv.hostPlatform.isSunOS,
  enableX11 ?
    stdenv.hostPlatform.isLinux
    || stdenv.hostPlatform.isFreeBSD
    || stdenv.hostPlatform.isOpenBSD
    || stdenv.hostPlatform.isSunOS,
  xorg,
  enableDrm ?
    stdenv.hostPlatform.isLinux
    || stdenv.hostPlatform.isFreeBSD
    || stdenv.hostPlatform.isOpenBSD
    || stdenv.hostPlatform.isSunOS,
  libdrm,
  enableDrmAmdgpu ? stdenv.hostPlatform.isLinux,
  enableGio ?
    stdenv.hostPlatform.isLinux
    || stdenv.hostPlatform.isFreeBSD
    || stdenv.hostPlatform.isOpenBSD
    || stdenv.hostPlatform.isSunOS,
  glib,
  enableDconf ?
    stdenv.hostPlatform.isLinux
    || stdenv.hostPlatform.isFreeBSD
    || stdenv.hostPlatform.isOpenBSD
    || stdenv.hostPlatform.isSunOS,
  dconf,
  enableDbus ?
    stdenv.hostPlatform.isLinux
    || stdenv.hostPlatform.isFreeBSD
    || stdenv.hostPlatform.isOpenBSD
    || stdenv.hostPlatform.isSunOS,
  dbus,
  enableXfconf ?
    stdenv.hostPlatform.isLinux
    || stdenv.hostPlatform.isFreeBSD
    || stdenv.hostPlatform.isOpenBSD
    || stdenv.hostPlatform.isSunOS,
  xfce,
  enableSqlite3 ?
    stdenv.hostPlatform.isLinux
    || stdenv.hostPlatform.isFreeBSD
    || stdenv.hostPlatform.isOpenBSD
    || stdenv.hostPlatform.isDarwin
    || stdenv.hostPlatform.isSunOS,
  sqlite,
  enableRpm ? stdenv.hostPlatform.isLinux,
  rpm,
  enableImagemagick ?
    stdenv.hostPlatform.isLinux
    || stdenv.hostPlatform.isDarwin
    || stdenv.hostPlatform.isFreeBSD
    || stdenv.hostPlatform.isOpenBSD
    || stdenv.hostPlatform.isWindows
    || stdenv.hostPlatform.isSunOS,
  imagemagick,
  enableChafa ? enableImagemagick,
  chafa,
  enableZlib ? enableImagemagick,
  zlib,
  enableEgl ?
    stdenv.hostPlatform.isLinux
    || stdenv.hostPlatform.isFreeBSD
    || stdenv.hostPlatform.isOpenBSD
    || stdenv.hostPlatform.isWindows
    || stdenv.hostPlatform.isSunOS,
  libGL,
  enableGlx ?
    stdenv.hostPlatform.isLinux
    || stdenv.hostPlatform.isFreeBSD
    || stdenv.hostPlatform.isOpenBSD
    || stdenv.hostPlatform.isSunOS,
  libglvnd,
  enableOsmesa ?
    stdenv.hostPlatform.isLinux
    || stdenv.hostPlatform.isFreeBSD
    || stdenv.hostPlatform.isOpenBSD
    || stdenv.hostPlatform.isSunOS,
  mesa,
  enableOpencl ?
    stdenv.hostPlatform.isLinux
    || stdenv.hostPlatform.isFreeBSD
    || stdenv.hostPlatform.isOpenBSD
    || stdenv.hostPlatform.isWindows
    || stdenv.hostPlatform.isAndroid
    || stdenv.hostPlatform.isSunOS,
  ocl-icd,
  opencl-headers,
  enableFreetype ? stdenv.hostPlatform.isAndroid,
  freetype,
  enablePulse ?
    stdenv.hostPlatform.isLinux || stdenv.hostPlatform.isOpenBSD || stdenv.hostPlatform.isSunOS,
  pulseaudio,
  enableDdcutil ? stdenv.hostPlatform.isLinux,
  ddcutil,
  enableDirectxHeaders ? stdenv.hostPlatform.isLinux,
  directx-headers,
  enableElf ? stdenv.hostPlatform.isLinux || stdenv.hostPlatform.isAndroid,
  libelf,
  enableLibzfs ?
    stdenv.hostPlatform.isLinux || stdenv.hostPlatform.isFreeBSD || stdenv.hostPlatform.isSunOS,
  zfs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fastfetch";
  version = "2.29.0";

  src = fetchFromGitHub {
    owner = "fastfetch-cli";
    repo = "fastfetch";
    rev = finalAttrs.version;
    hash = "sha256-qXzE2v2BS1CgPVPIj+mct9zoJ4hpNCsTZ12keQThRZI=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    python3
  ];

  buildInputs =
    [ yyjson_0_10 ]
    ++ lib.optional enableVulkan vulkan-loader
    ++ lib.optional enableWayland wayland
    ++ lib.optional (enableXcb || enableXcbRandr) xorg.libxcb
    ++ lib.optional enableXrandr xorg.libXrandr
    ++ lib.optional enableX11 xorg.libX11
    ++ lib.optional (enableDrm || enableDrmAmdgpu) libdrm
    ++ lib.optional enableGio glib
    ++ lib.optional enableDconf dconf
    ++ lib.optional enableDbus dbus
    ++ lib.optional enableXfconf xfce.xfconf
    ++ lib.optional enableSqlite3 sqlite
    ++ lib.optional enableRpm rpm
    ++ lib.optional enableImagemagick imagemagick
    ++ lib.optional enableChafa chafa
    ++ lib.optional enableZlib zlib
    ++ lib.optional enableEgl libGL
    ++ lib.optional enableGlx libglvnd
    ++ lib.optional enableOsmesa mesa
    ++ lib.optionals enableOpencl [
      ocl-icd
      opencl-headers
    ]
    ++ lib.optional enableFreetype freetype
    ++ lib.optional enablePulse pulseaudio
    ++ lib.optional enableDdcutil ddcutil
    ++ lib.optional enableDirectxHeaders directx-headers
    ++ lib.optional enableElf libelf
    ++ lib.optional enableLibzfs zfs;

  cmakeFlags = [
    (lib.cmakeOptionType "filepath" "CMAKE_INSTALL_SYSCONFDIR" "${placeholder "out"}/etc")
    (lib.cmakeBool "ENABLE_SYSTEM_YYJSON" true)
    (lib.cmakeBool "ENABLE_VULKAN" enableVulkan)
    (lib.cmakeBool "ENABLE_WAYLAND" enableWayland)
    (lib.cmakeBool "ENABLE_XCB" enableXcb)
    (lib.cmakeBool "ENABLE_XCB_RANDR" enableXcbRandr)
    (lib.cmakeBool "ENABLE_XRANDR" enableXrandr)
    (lib.cmakeBool "ENABLE_X11" enableX11)
    (lib.cmakeBool "ENABLE_DRM" enableDrm)
    (lib.cmakeBool "ENABLE_DRM_AMDGPU" enableDrmAmdgpu)
    (lib.cmakeBool "ENABLE_GIO" enableGio)
    (lib.cmakeBool "ENABLE_DCONF" enableDconf)
    (lib.cmakeBool "ENABLE_DBUS" enableDbus)
    (lib.cmakeBool "ENABLE_XFCONF" enableXfconf)
    (lib.cmakeBool "ENABLE_SQLITE3" enableSqlite3)
    (lib.cmakeBool "ENABLE_RPM" enableRpm)
    (lib.cmakeBool "ENABLE_IMAGEMAGICK7" enableImagemagick)
    (lib.cmakeBool "ENABLE_IMAGEMAGICK6" false)
    (lib.cmakeBool "ENABLE_CHAFA" enableChafa)
    (lib.cmakeBool "ENABLE_ZLIB" enableZlib)
    (lib.cmakeBool "ENABLE_EGL" enableEgl)
    (lib.cmakeBool "ENABLE_GLX" enableGlx)
    (lib.cmakeBool "ENABLE_OSMESA" enableOsmesa)
    (lib.cmakeBool "ENABLE_OPENCL" enableOpencl)
    (lib.cmakeBool "ENABLE_FREETYPE" enableFreetype)
    (lib.cmakeBool "ENABLE_PULSE" enablePulse)
    (lib.cmakeBool "ENABLE_DDCUTIL" enableDdcutil)
    (lib.cmakeBool "ENABLE_DIRECTX_HEADERS" enableDirectxHeaders)
    (lib.cmakeBool "ENABLE_ELF" enableElf)
    (lib.cmakeBool "ENABLE_LIBZFS" enableLibzfs)
    # Requires networking
    (lib.cmakeBool "ENABLE_EMBEDDED_PCIIDS" false)
  ];

  passthru = {
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };

    updateScript = nix-update-script { };
  };

  meta = {
    mainProgram = "fastfetch";
    description = "Like neofetch, but much faster because written in C";
    homepage = "https://github.com/fastfetch-cli/fastfetch";
    changelog = "https://github.com/fastfetch-cli/fastfetch/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
