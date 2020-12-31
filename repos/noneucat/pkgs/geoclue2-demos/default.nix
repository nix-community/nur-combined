{ stdenv, geoclue2, glib, glibc }:

stdenv.mkDerivation {
  pname = "geoclue-demos";
  version = geoclue2.version;

  src = geoclue2.src;

  buildInputs = [
    geoclue2
    glib
    glibc
  ];

  patchPhase = ''
    sed -i "s/\#include <config.h>//g" demo/where-am-i.c
  '';

  buildPhase = ''
    gcc  \
      -DGETTEXT_PACKAGE=\"geoclue\"       \
      -DLOCALEDIR=\"\" \
      -I${glib.out}/lib/glib-2.0/include  \
      -I${glib.dev}/include/glib-2.0      \
      -I${geoclue2.dev}/include/libgeoclue-2.0 \
      -lglib-2.0 -lgio-2.0 -lgobject-2.0 -lgeoclue-2 \
      demo/where-am-i.c -o where-am-i
  '';

  enableDebugInfo = true;

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 where-am-i $out/bin
  '';
}


