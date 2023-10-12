{ lib
, stdenv
, fetchFromGitHub
, cmake
, darwin
, ninja
, pkg-config
, yyjson

, enableLibpci ? stdenv.isLinux || stdenv.isBSD
, pciutils
, enableVulkan ? stdenv.isLinux || stdenv.isDarwin || stdenv.isBSD || stdenv.isCygwin
, vulkan-loader
, enableWayland ? stdenv.isLinux || stdenv.isBSD
, wayland
, enableXcb ? stdenv.isLinux || stdenv.isBSD
, enableXcbRandr ? stdenv.isLinux || stdenv.isBSD
, enableXrandr ? stdenv.isLinux || stdenv.isBSD
, enableX11 ? stdenv.isLinux || stdenv.isBSD
, xorg
, enableGio ? stdenv.isLinux || stdenv.isBSD
, glib
, enableDconf ? stdenv.isLinux || stdenv.isBSD
, dconf
, enableDbus ? stdenv.isLinux || stdenv.isBSD
, dbus
, enableXfconf ? stdenv.isLinux || stdenv.isBSD
, xfce
, enableSqlite3 ? stdenv.isLinux || stdenv.isBSD || stdenv.isDarwin
, sqlite
, enableRpm ? stdenv.isLinux
, rpm
, enableImagemagick7 ? stdenv.isLinux || stdenv.isDarwin || stdenv.isBSD || stdenv.isCygwin
, imagemagick
, enableChafa ? enableImagemagick7
, chafa
, enableZlib ? enableImagemagick7
, zlib
, enableEgl ? stdenv.isLinux || stdenv.isBSD
, libGL
, enableGlx ? stdenv.isLinux || stdenv.isBSD
, libglvnd
, enableOsmesa ? stdenv.isLinux || stdenv.isBSD
, mesa_drivers
, enableOpencl ? stdenv.isLinux || stdenv.isBSD
, ocl-icd
, opencl-headers
, enableLibnm ? stdenv.isLinux
, networkmanager
, enableFreetype ? stdenv.isLinux # Android
, freetype
, enablePulse ? stdenv.isLinux || stdenv.isBSD
, pulseaudio
, enableDdcutil ? stdenv.isLinux
, ddcutil
, enableDirectxHeaders ? stdenv.isLinux
, directx-headers
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fastfetch";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "LinusDierheimer";
    repo = "fastfetch";
    rev = finalAttrs.version;
    hash = "sha256-4FkBq7UxwZ2YuC4t/siC3CXqyP3Lff4jW3xheAQ9M6o=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    yyjson
  ]
  ++ lib.optional enableLibpci pciutils
  ++ lib.optionals enableVulkan ([ vulkan-loader ] ++ lib.optional stdenv.isDarwin darwin.moltenvk)
  ++ lib.optional enableWayland wayland
  ++ lib.optional (enableXcb || enableXcbRandr) xorg.libxcb
  ++ lib.optional enableXrandr xorg.libXrandr
  ++ lib.optional enableX11 xorg.libX11
  ++ lib.optional enableGio glib
  ++ lib.optional enableDconf dconf
  ++ lib.optional enableDbus dbus
  ++ lib.optional enableXfconf xfce.xfconf
  ++ lib.optional enableSqlite3 sqlite
  ++ lib.optional enableRpm rpm
  ++ lib.optional enableImagemagick7 imagemagick
  ++ lib.optional enableChafa chafa
  ++ lib.optional enableZlib zlib
  ++ lib.optional enableEgl libGL
  ++ lib.optional enableGlx libglvnd
  ++ lib.optional enableOsmesa mesa_drivers.dev
  ++ lib.optionals enableOpencl [ ocl-icd opencl-headers ]
  ++ lib.optional enableLibnm networkmanager
  ++ lib.optional enableFreetype freetype
  ++ lib.optional enablePulse pulseaudio
  ++ lib.optional enableDdcutil ddcutil
  ++ lib.optional enableDirectxHeaders directx-headers
  ;

  cmakeFlags = [
    "-DTARGET_DIR_ROOT=${placeholder "out"}"
    "-DENABLE_SYSTEM_YYJSON=ON"

    (lib.cmakeBool "ENABLE_LIBPCI" enableLibpci)
    (lib.cmakeBool "ENABLE_VULKAN" enableVulkan)
    (lib.cmakeBool "ENABLE_WAYLAND" enableWayland)
    (lib.cmakeBool "ENABLE_XCB" enableXcb)
    (lib.cmakeBool "ENABLE_XCB_RANDR" enableXcbRandr)
    (lib.cmakeBool "ENABLE_XRANDR" enableXrandr)
    (lib.cmakeBool "ENABLE_X11" enableX11)
    (lib.cmakeBool "ENABLE_GIO" enableGio)
    (lib.cmakeBool "ENABLE_DCONF" enableDconf)
    (lib.cmakeBool "ENABLE_DBUS" enableDbus)
    (lib.cmakeBool "ENABLE_XFCONF" enableXfconf)
    (lib.cmakeBool "ENABLE_SQLITE3" enableSqlite3)
    (lib.cmakeBool "ENABLE_RPM" enableRpm)
    (lib.cmakeBool "ENABLE_IMAGEMAGICK7" enableImagemagick7)
    (lib.cmakeBool "ENABLE_CHAFA" enableChafa)
    (lib.cmakeBool "ENABLE_ZLIB" enableZlib)
    (lib.cmakeBool "ENABLE_EGL" enableEgl)
    (lib.cmakeBool "ENABLE_GLX" enableGlx)
    (lib.cmakeBool "ENABLE_OSMESA" enableOsmesa)
    (lib.cmakeBool "ENABLE_OPENCL" enableOpencl)
    (lib.cmakeBool "ENABLE_LIBNM" enableLibnm)
    (lib.cmakeBool "ENABLE_FREETYPE" enableFreetype)
    (lib.cmakeBool "ENABLE_PULSE" enablePulse)
    (lib.cmakeBool "ENABLE_DDCUTIL" enableDdcutil)
    (lib.cmakeBool "ENABLE_DIRECTX_HEADERS" enableDirectxHeaders)
  ];

  meta = with lib; {
    description = "Like neofetch, but much faster because written in C";
    homepage = "https://github.com/LinusDierheimer/fastfetch";
    changelog = "https://github.com/LinusDierheimer/fastfetch/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ federicoschonborn ];
  };
})
