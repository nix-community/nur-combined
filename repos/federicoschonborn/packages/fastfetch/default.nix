{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  darwin,
  pkg-config,
  enableLibpci ? false,
  pciutils,
  enableVulkan ? false,
  vulkan-loader,
  enableWayland ? false,
  libffi,
  wayland,
  enableXcb ? false,
  enableXrandr ? false,
  enableX11 ? false,
  xorg,
  enableGio ? false,
  glib,
  libselinux,
  libsepol,
  pcre16,
  pcre2,
  utillinux,
  enableDconf ? false,
  dconf,
  enableDbus ? false,
  dbus,
  enableXfconf ? false,
  xfce,
  enableSqlite3 ? false,
  sqlite,
  enableRpm ? false,
  rpm,
  enableImagemagick7 ? false,
  imagemagick,
  enableZlib ? false,
  zlib,
  enableChafa ? false,
  chafa,
  enableEgl ? false,
  libGL,
  enableGlx ? false,
  libglvnd,
  enableMesa ? false,
  mesa_drivers,
  enableOpencl ? false,
  ocl-icd,
  opencl-headers,
  enableLibcjson ? false,
  cjson,
  enableLibnm ? false,
  networkmanager,
  enableFreetype ? false,
  freetype,
  enablePulse ? false,
  pulseaudio,
}:
stdenv.mkDerivation rec {
  pname = "fastfetch";
  version = "1.10.2";

  src = fetchFromGitHub {
    owner = "LinusDierheimer";
    repo = "fastfetch";
    rev = version;
    hash = "sha256-hQVqfCCnBjcsG+xIPTIM7jblXOGqZjJ/zsxOB79vAqQ=";
  };

  nativeBuildInputs =
    [
      cmake
      pkg-config
    ]
    ++ lib.optionals enableLibpci [pciutils]
    ++ lib.optionals enableVulkan [vulkan-loader]
    ++ lib.optionals enableWayland [libffi wayland]
    ++ lib.optionals enableXcb [xorg.libXau xorg.libXdmcp xorg.libxcb]
    ++ lib.optionals enableXrandr [xorg.libXext xorg.libXrandr]
    ++ lib.optionals enableX11 [xorg.libX11]
    # glib depends on pcre2
    # libselinux depends on pcre16
    ++ lib.optionals enableGio [glib libselinux libsepol pcre16 pcre2 utillinux]
    ++ lib.optionals enableDconf [dconf]
    ++ lib.optionals enableDbus [dbus]
    ++ lib.optionals enableXfconf [xfce.xfconf]
    ++ lib.optionals enableSqlite3 [sqlite]
    ++ lib.optionals enableRpm [rpm]
    ++ lib.optionals enableImagemagick7 [imagemagick]
    ++ lib.optionals enableZlib [zlib]
    ++ lib.optionals enableChafa [chafa]
    ++ lib.optionals enableEgl [libGL]
    ++ lib.optionals enableGlx [libglvnd]
    ++ lib.optionals enableMesa [mesa_drivers.dev]
    ++ lib.optionals enableOpencl [ocl-icd opencl-headers]
    ++ lib.optionals enableLibcjson [cjson]
    ++ lib.optionals enableLibnm [networkmanager]
    ++ lib.optionals enableFreetype [freetype]
    ++ lib.optionals enablePulse [pulseaudio]
    ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
      CoreFoundation
      IOKit
      OpenGL
      OpenCL
      Cocoa
      CoreWLAN
      CoreAudio
      CoreVideo
      IOBluetooth
    ]);

  meta = with lib; {
    description = "Like neofetch, but much faster because written in C";
    homepage = "https://github.com/LinusDierheimer/fastfetch";
    changelog = "https://github.com/LinusDierheimer/fastfetch/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
  };
}
