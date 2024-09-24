{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, makeWrapper
, unzip
, libGL
, glib
, fontconfig
, xorg
, xkeyboard_config
, dbus
, wayland
, libxkbcommon 
, libxml2
}:
stdenv.mkDerivation {
  pname = "binaryninja";
  version = "4.1";

  buildInputs = [
    unzip
    libGL
    stdenv.cc.cc.lib
    glib
    fontconfig
    dbus
    wayland
    libxml2
    libxkbcommon
    xorg.libXi
    xorg.libXrender
    xorg.xcbutilrenderutil
    xorg.xcbutilimage
    xorg.xcbutilwm
    xorg.xcbutilkeysyms
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  src = fetchurl {
    url = "https://cdn.binary.ninja/installers/binaryninja_free_linux.zip";
    hash = "sha256-OCMOJKC0X0mGV3snfeumzHCXrnjobQb78dWQFv73uU4=";
  };

  #buildPhase = ":";
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/opt
    cp -r * $out/opt
    chmod +x $out/opt/binaryninja
    makeWrapper $out/opt/binaryninja \
        $out/bin/binaryninja \
        --prefix "QT_XKB_CONFIG_ROOT" ":" "${xkeyboard_config}/share/X11/xkb"
  '';

  meta = with lib; {
    description = "Binary Ninja is an interactive decompiler, disassembler, debugger, and binary analysis platform built by reverse engineers, for reverse engineers. (Free version)";
    homepage = "https://binary.ninja/";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
