{ lib
, llvmPackages
, s2e
, cmake
, pkg-config
, glib
}:

llvmPackages.stdenv.mkDerivation rec {
  pname = "s2e-libcoroutine";
  inherit (s2e) version src;

  patchPhase = ''
    # note: stay in this directory for build
    cd libcoroutine
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    glib
  ];

  installPhase = ''
    mkdir -p $out/lib
    cp src/libcoroutine.a $out/lib
    cp -r ../include $out
  '';
}
