{ stdenv
, lib
, fetchurl
, alsaLib
, atk
, bzip2
, cairo
, curl
, expat
, fontconfig
, freetype
, gdk-pixbuf
, glib
, glibc
, graphite2
, gtk2
, harfbuzz
, libICE
, libSM
, libX11
, libXau
, libXcomposite
, libXcursor
, libXdamage
, libXdmcp
, libXext
, libXfixes
, libXi
, libXinerama
, libXrandr
, libXrender
, libXt
, libXxf86vm
, libdrm
, libffi
, libglvnd
, libpng
, libvdpau
, libxcb
, libxshmfence
, nspr
, nss
, pango
, pcre
, pixman
, zlib
, p7zip
}:

let
  arch =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      "x86_64"
    else if stdenv.hostPlatform.system == "i686-linux"   then
      "i386"
    else throw "Flash Player is not supported on this platform";
  flash_suffix =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      "64"
    else
      "32";
  lib_suffix =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      "64"
    else
      "";
in
stdenv.mkDerivation rec {
  pname = "flashplayer";
  version = "32.0.0.465";

  src = fetchurl {
    url =
      "http://files3.swfchan.com/end/FlashPluginsFixed_32.0.0.465_WindowsLinux.7z";
    sha256 =
      "1zzbp9y3ilh368zcm40c24k3zwjpdaacs5r8wpi1v1ql5g549h5d";
  };

  nativeBuildInputs = [ p7zip ];

  sourceRoot = ".";

  dontStrip = true;
  dontPatchELF = true;

  preferLocalBuild = true;

  installPhase = ''
    mkdir -p $out/lib/mozilla/plugins
    cp -pv FlashPluginsFixed_32.0.0.465_WindowsLinux/linux/linux_${flash_suffix}-bit_NPAPI_libflashplayer--fixed.so $out/lib/mozilla/plugins/libflashplayer.so
    chmod +x $out/lib/mozilla/plugins/libflashplayer.so
    patchelf --set-rpath "$rpath" \
      $out/lib/mozilla/plugins/libflashplayer.so
  '';

  passthru = {
    mozillaPlugin = "/lib/mozilla/plugins";
  };

  rpath = lib.makeLibraryPath
    [ stdenv.cc.cc
      alsaLib atk bzip2 cairo curl expat fontconfig freetype gdk-pixbuf glib
      glibc graphite2 gtk2 harfbuzz libICE libSM libX11 libXau libXcomposite
      libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama
      libXrandr libXrender libXt libXxf86vm libdrm libffi libglvnd libpng
      libvdpau libxcb libxshmfence nspr nss pango pcre pixman zlib
    ];

  meta = {
    description = "Adobe Flash Player browser plugin";
    homepage = "http://swfchan.com/end/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" "i686-linux" ];
  };
}
