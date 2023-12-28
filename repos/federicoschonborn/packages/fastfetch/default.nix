{ lib
, stdenv
, fetchFromGitHub
, cmake
, ninja
, pkg-config
, yyjson
, nix-update-script

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
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "LinusDierheimer";
    repo = "fastfetch";
    rev = finalAttrs.version;
    hash = "sha256-LHRbobgBXGjoLQXC+Gy03aNrTyjn1loVMbj0qv3HObQ=";
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
  ++ lib.optional enableVulkan vulkan-loader
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
  ++ lib.optional enableDirectxHeaders directx-headers;

  env.NIX_CFLAGS_COMPILE = "-Wno-error=uninitialized";

  cmakeFlags =
    let
      # For compatability with old Nixpkgs
      cmakeBool = lib.cmakeBool or (name: value: "-D${name}:BOOL=${if value then "ON" else "OFF"}");
    in
    [
      "-DTARGET_DIR_ROOT=${placeholder "out"}"
      "-DENABLE_SYSTEM_YYJSON=ON"

      (cmakeBool "ENABLE_LIBPCI" enableLibpci)
      (cmakeBool "ENABLE_VULKAN" enableVulkan)
      (cmakeBool "ENABLE_WAYLAND" enableWayland)
      (cmakeBool "ENABLE_XCB" enableXcb)
      (cmakeBool "ENABLE_XCB_RANDR" enableXcbRandr)
      (cmakeBool "ENABLE_XRANDR" enableXrandr)
      (cmakeBool "ENABLE_X11" enableX11)
      (cmakeBool "ENABLE_GIO" enableGio)
      (cmakeBool "ENABLE_DCONF" enableDconf)
      (cmakeBool "ENABLE_DBUS" enableDbus)
      (cmakeBool "ENABLE_XFCONF" enableXfconf)
      (cmakeBool "ENABLE_SQLITE3" enableSqlite3)
      (cmakeBool "ENABLE_RPM" enableRpm)
      (cmakeBool "ENABLE_IMAGEMAGICK7" enableImagemagick7)
      (cmakeBool "ENABLE_CHAFA" enableChafa)
      (cmakeBool "ENABLE_ZLIB" enableZlib)
      (cmakeBool "ENABLE_EGL" enableEgl)
      (cmakeBool "ENABLE_GLX" enableGlx)
      (cmakeBool "ENABLE_OSMESA" enableOsmesa)
      (cmakeBool "ENABLE_OPENCL" enableOpencl)
      (cmakeBool "ENABLE_LIBNM" enableLibnm)
      (cmakeBool "ENABLE_FREETYPE" enableFreetype)
      (cmakeBool "ENABLE_PULSE" enablePulse)
      (cmakeBool "ENABLE_DDCUTIL" enableDdcutil)
      (cmakeBool "ENABLE_DIRECTX_HEADERS" enableDirectxHeaders)
    ];

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "fastfetch";
    description = "Like neofetch, but much faster because written in C";
    homepage = "https://github.com/LinusDierheimer/fastfetch";
    changelog = "https://github.com/LinusDierheimer/fastfetch/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
