{ lib
, llvmPackages
, s2e
, cmake
, pkg-config
, glib
}:

llvmPackages.stdenv.mkDerivation rec {
  pname = "s2e-libq";
  inherit (s2e) version src;

  patchPhase = ''
    # note: stay in this directory for build
    cd libq
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    glib
  ];

  # TODO dont build: check-qlist check-qdict check-qnull check-qjson check-qnum check-qstring check-qobject

  installPhase = ''
    mkdir -p $out/lib
    cp src/libq.a $out/lib

    cd .. # leave build/
    cp -r include $out # install qqueue.h etc
  '';
}
